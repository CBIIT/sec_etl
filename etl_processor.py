from datetime import datetime
from functools import wraps
from os import environ, makedirs
from os.path import basename, dirname, join as pjoin
import re
import traceback


OUTPUT_DIR = 'etl_output'

# Per-script force flags. Each script's flag is FORCE_ plus its file stem
# upper-cased: api_etl_v2.py -> FORCE_API_ETL_V2. FORCE_ALL forces every step.
#
# etl.qmd runs each script with runpy in this same process, so the environment
# is visible to the scripts directly -- no argv plumbing is needed. That
# matters because --force is a store_true flag, and _run_script builds argv as
# key/value pairs, which cannot express a valueless flag.
FORCE_ALL_ENV = 'FORCE_ALL'
_TRUTHY = {'1', 'true', 't', 'yes', 'y', 'on'}


def force_env_name(python_file):
    """FORCE_<SCRIPT> for the given script path."""
    return 'FORCE_' + basename(python_file).removesuffix('.py').upper()


def _is_truthy(value):
    return value is not None and value.strip().lower() in _TRUTHY


def force_requested(python_file):
    """True when this script's force flag, or FORCE_ALL, is set and truthy.

    An unset variable and an explicitly falsey one ('0', 'false', 'off', '')
    both mean "do not force", so a flag can be turned off in place rather than
    having to be deleted.
    """
    if _is_truthy(environ.get(force_env_name(python_file))):
        return True
    return _is_truthy(environ.get(FORCE_ALL_ENV))


def active_force_flags(python_files):
    """Names of the force flags currently in effect, for reporting."""
    active = []
    if _is_truthy(environ.get(FORCE_ALL_ENV)):
        active.append(FORCE_ALL_ENV)
    for python_file in python_files:
        name = force_env_name(python_file)
        if _is_truthy(environ.get(name)):
            active.append(name)
    return active

# The read-only role the SEC apps use to query ETL output. Created by
# sec_db_setup.sh; ensure_role() re-creates it defensively if it is missing.
READ_ROLE = 'sec_read'

# DDL cannot be parameterized, so identifiers are interpolated. Everything we
# interpolate is a literal in our own source, but validate anyway.
_IDENT_RE = re.compile(r'^[A-Za-z_][A-Za-z0-9_]*$')


def _etl_timestamp():
    # %H:%M:%S -- the colons are required; without them a time reads as
    # "154327.655" instead of "15:43:27.655". [:-3] trims microseconds to ms.
    return datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f')[:-3]


def etl_printer(func):
    @wraps(func)
    def wrapper(processor, *args, **kwargs):
        processor.pr(func.__name__, 'STARTED', _etl_timestamp())
        try:
            result = func(processor, *args, **kwargs)
        except Exception as exc:
            processor.pre(func.__name__, traceback.format_exc())
            # FAILED, not COMPLETED. This used to print COMPLETED from a
            # `finally:`, which put the word "COMPLETED" directly underneath
            # every traceback -- the log read as a success at a glance.
            processor.pre(func.__name__, 'FAILED', _etl_timestamp())
            raise exc
        processor.pr(func.__name__, 'COMPLETED', _etl_timestamp())
        return result

    return wrapper


class EtlProcessor:
    def __init__(self, name=None, args=None, python_file=None):
        self.name = name
        self._args = args
        # Tracks whether this run hit a fatal error. process() returns it and
        # each script assigns it to a module-level `success`, which etl.qmd
        # reads out of the module namespace to decide pass/fail. Without it a
        # caught-and-logged exception would be reported as a successful step.
        self._succeeded = True
        self.python_file = python_file or __file__
        self._output_file = pjoin(
            OUTPUT_DIR,
            f'{basename(self.python_file).removesuffix(".py")}.txt',
        )
        output_dir = dirname(self._output_file)
        if output_dir:
            makedirs(output_dir, exist_ok=True)
        # Start this run's log fresh. pr()/pre() then append one flushed line at
        # a time directly to the output file -- no in-memory buffer is kept.
        open(self._output_file, 'w', encoding='utf-8').close()

    @property
    def args(self):
        return self._args

    @property
    def output_file(self):
        return self._output_file

    @property
    def succeeded(self):
        return self._succeeded

    def fail(self, *args, **kwargs):
        """
        Record a fatal failure: mark the run failed and log it like pre().

        Use this instead of pre() in a top-level `except` so the failure
        reaches etl.qmd. pre() alone only writes to the log, which is how
        a failed step could previously be reported as green.
        """
        self._succeeded = False
        self.pre(*args, **kwargs)

    def _append_line(self, *args, **kwargs):
        # Append a single line to the output file and flush it to disk
        # immediately so the log reflects progress as it happens.
        kwargs.pop('file', None)
        kwargs['flush'] = True
        with open(self._output_file, 'a', encoding='utf-8') as output_handle:
            print(*args, file=output_handle, **kwargs)

    def pr(self, *args, **kwargs):
        self._append_line(*args, **kwargs)

    def pre(self, *args, **kwargs):
        self._append_line('ERROR:', *args, **kwargs)

    def ensure_role(self, con, role=READ_ROLE):
        """
        Make sure `role` exists so that GRANT statements against it succeed.

        Creating a role requires CREATEROLE or superuser, which the application
        user may not have (prod runs as `secapp`). This is therefore best-effort:
        on any failure it rolls back, logs, and returns False so the caller can
        continue. The role is created NOLOGIN -- it only needs to be a valid
        GRANT target here; sec_db_setup.sh creates the real login user.

        Returns True if the role exists (or was created), False otherwise.
        """
        if not _IDENT_RE.match(role):
            self.pre(f'refusing to create role with unexpected name: {role!r}')
            return False
        try:
            with con.cursor() as cur:
                cur.execute('select 1 from pg_roles where rolname = %s', (role,))
                if cur.fetchone() is not None:
                    return True
                cur.execute(f'create role {role}')
            con.commit()
            self.pr(f'created missing role {role}')
            return True
        except Exception as exc:
            con.rollback()
            self.pr(f'NOTE: could not ensure role {role} exists ({exc}); continuing')
            return False

    def grant_select(self, con, table, role=READ_ROLE):
        """
        Grant SELECT on `table` to `role`, best-effort.

        Call this anywhere a table is CREATEd, because CREATE TABLE starts with
        no grants -- dropping and recreating a table silently revokes access the
        read-only role previously had. Never fatal: a failure here must not abort
        an otherwise successful ETL run.
        """
        if not (_IDENT_RE.match(table) and _IDENT_RE.match(role)):
            self.pre(f'refusing to grant on unexpected identifier: {table!r} -> {role!r}')
            return False
        try:
            with con.cursor() as cur:
                cur.execute(f'grant select on {table} to {role}')
            con.commit()
            self.pr(f'granted select on {table} to {role}')
            return True
        except Exception as exc:
            con.rollback()
            self.pr(f'NOTE: grant select on {table} to {role} failed ({exc}); continuing')
            return False

    def post_process(self):
        # Output is now written incrementally and flushed by pr()/pre(), so the
        # buffer flush this method used to perform is no longer needed. Retained
        # as a no-op so existing `super().post_process()` calls remain valid.
        pass
