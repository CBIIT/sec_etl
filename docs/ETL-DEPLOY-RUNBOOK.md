# SEC ETL — Deploy Runbook & Session History (2026-09-15/16)

Companion to [SEC-HANDOFF.md](SEC-HANDOFF.md). That document covers the project setup;
this one covers **the ETL report rewrite, the production deploy, and everything learned
about publishing to Posit Connect**. Read §2 before ever deploying sec_etl again.

---

## 1. Executive summary

- The ETL report was rewritten to detect and report step failures. It is now `etl.qmd`;
  the previous document is preserved verbatim as `etl-orig.qmd`.
- **Production had been running a near-no-op every night since 2026-03-22.** Six of seven
  ETL steps were disabled by `eval: false` in the deployed bundle. Nightly runs took
  **26–27 seconds**. This was only discovered by reading Connect's job history.
- Bundle **10815** was published 2026-09-15 16:47 and is **active**. The first real ETL in
  ~6 months ran that night (3h 08m).
- `associations` had been left **empty** in prod by an earlier failed run. It is now
  repaired (6,924 rows).
- The three NLP steps were **skipped** by the `MIN_EXP_TRIALS` gate and will keep being
  skipped nightly until the threshold is lowered. **This is the top open item.**

---

## 2. Posit Connect — publishing gotchas (READ FIRST)

### 2.1 There are TWO apps named `sec_etl` on posit-connect-prod

| | GUID | numeric id | name | Notes |
|---|---|---|---|---|
| **PRODUCTION** | `67177a19-f8eb-479e-a7de-bb5d87010bc8` | **14** | `sec-etl-prod` | daily 18:00 schedule, emails collaborators |
| personal copy | `ee78cbdc-81e0-43ef-a353-9b1c1f750d2b` | — | *(empty)* | last deployed 2026-01-27, bundle 2294 |

Both have `title = "sec_etl"`, which makes them **indistinguishable in the Connect content
listing**. Hours were lost to this: a bundle downloaded from the personal copy was mistaken
for production and led to wrong conclusions about what prod was running.

The `name` field on the production app was blank; it was set to `sec-etl-prod` via the API so
the two can be told apart. **A blank `name` does NOT hide content** — several apps on this
server have blank names and list fine. If an app seems "missing" from the listing, suspect
duplicate titles before suspecting permissions.

Consider also retitling so the UI distinguishes them:

```bash
curl -s -X PATCH -H "Authorization: Key $CONNECT_API_KEY" -H "Content-Type: application/json" \
  -d '{"title":"sec_etl (PROD ETL)"}' \
  "https://posit-connect-prod.cancer.gov/__api__/v1/content/67177a19-f8eb-479e-a7de-bb5d87010bc8"
```

### 2.2 Deploying sec_etl RUNS THE ENTIRE ETL

`etl.qmd` is `quarto-static`: Connect **renders it at deploy time**, and rendering *is* the
ETL — NCIt load, 6.4M-row transitive closure, ~3,900 trials from the CTS API, NLP. Expect
**3+ hours**, against the production database.

Consequences:
- A deploy is not a lightweight action. Treat it as "start a production ETL run".
- **Never deploy near 18:00** (see §2.4).
- **Never retry a stalled deploy** without checking the job history first — a second render
  means two concurrent ETLs dropping and recreating the same tables.

### 2.3 "Deploying your project — waiting for server" is normal and slow

Publisher sat on this message for ~13 minutes. That was Connect restoring the Python
environment, not a hang:

```
329027  16:48:01 → 17:01:32  python_restore  exit 0   (13.5 min)
```

`requirements.txt` builds spacy / numpy / pandas / blis. Wait it out. The client-side and
server-side logs are separate — in VS Code use the Command Palette:

- `Posit Publisher: Show Publishing Log` — client side (bundling, upload)
- `Posit Publisher: View Deployed Content Log` — server side (pip, quarto render, ETL output)
- `Posit Publisher: Show Debug Log` — extension itself
- `Open Raw Logs` / `Copy Logs` — from the Publisher Log panel

### 2.4 There is a daily 18:00 schedule — it collided with the deploy

```
329044  17:01:33 → 20:10:15  build_report  3h 08m   <- the deploy's render
329109  18:00:53 → 21:11:24  build_report  3h 10m   <- the SCHEDULED run
```

These **overlapped by 2h 09m**: two full ETLs writing the same tables simultaneously. Both
exited 0 and the end state was coherent, but this must not be repeated.

### 2.5 The variant's `bundle_id` is stale — trust `active: true`

`/__api__/applications/14/variants` reported `bundle_id: 4506` *after* 10815 was live. The
authoritative signal is the bundles endpoint:

```bash
curl -s -H "Authorization: Key $CONNECT_API_KEY" \
  "https://posit-connect-prod.cancer.gov/__api__/v1/content/67177a19-f8eb-479e-a7de-bb5d87010bc8/bundles" \
  | python3 -m json.tool | grep -B3 '"active": true'
```

Runtime behaviour corroborates: 27-second runs = old bundle, 3-hour runs = new bundle.

### 2.6 Tooling limits found the hard way

- **No `publisher` CLI** exists on this machine; the VS Code extension ships no binary.
  Deploys **must** be done from the VS Code Publisher panel by a human.
- **Browser automation is blocked** for `posit-connect-prod.cancer.gov`
  (*"Navigation to this domain is not allowed"*), so the Connect UI cannot be driven
  programmatically. Use the **Connect REST API** with a personal API key instead (§6).
- The Connect server *is* reachable from the shell (`/__api__/server_settings` → HTTP 200).

### 2.7 `etl_processor.py` must be in the bundle

Every ETL script now does `from etl_processor import ...`. The module was **missing** from
both publish configs' `files` lists — the bundle would have failed at import on step 1.
Fixed in commit `4e2b9f0`. **Verify it survives any Publisher-driven rewrite of the config.**

### 2.8 Repo hygiene that affects publishing

- `sec_poc/postgres_data_dir-bkup/` is **1.9 GB / 1,637 files** — 95% of the 2.0 GB project.
  Untracked *and* un-ignored. Publisher walks the whole tree; add a `.positignore`.
- A local env file contained **live API keys** and was not gitignored in a public repo.
  `*.env` is now in `.gitignore`. Rotate any key that sat exposed. **Never commit env files.**

---

## 3. What changed in the code

All pushed unless noted.

### `sec_etl` (branch `main`)

| Commit | What |
|---|---|
| `b6a83ee` | Failure reporting + log timestamp fix |
| `bd58608` | `etl-new.qmd` → `etl.qmd`; old doc preserved as `etl-orig.qmd` |
| `4e2b9f0` | Add `etl_processor.py` to the Posit bundle file list |
| `c6a11b3` | Restore the NLP trial-count gate as `MIN_EXP_TRIALS` |
| `038db39` | Document `MIN_EXP_TRIALS`; refresh handoff doc |

### `sec_nlp` (`main`) — `e82584e`, `8c193aa`
### `sec_poc` (`master`) — `8ad2723`, `fc75320`

Wrapped all seven ETL scripts in `EtlProcessor` subclasses. Verified by AST comparison that
logic was preserved: SQL literal multisets unchanged, five `re.VERBOSE` regexes
**byte-identical**, tokenizer stopword lists identical (including duplicate `'who'`/`'at'`),
and the `nlp_tokenizer` zip-iterator quirk preserved verbatim.

Bugs fixed along the way:
- `get_associations`: `execute_batch` called with transposed arguments (raised at runtime).
- `get_associations`: unguarded `GRANT SELECT ... TO sec_read` aborted the run where the role
  was missing — now best-effort `ensure_role()` / `grant_select()`.
- `sec_poc_tokenizer`: orphan cleanup re-ran the wrong DELETE, so `candidate_criteria`
  orphans were never purged.
- `sec_poc_tokenizer`: `nlp_data_tab` is dropped/recreated each run, discarding the grant
  applied earlier by `refresh_ncit_pg` — now re-granted at the creation site.
- `etl_processor`: timestamps rendered as `154327.655`; now `15:43:27.655`.

### `py_misc` — ⚠️ `a6abf26` **NOT PUSHED** (credential prompt unavailable)

`matt/bin/sec_db_setup.sh` rewritten: idempotent, `SUPERUSER` override, fixed a `psql secapp`
call against a database that never existed, reader/writer grants, and `ALTER DEFAULT
PRIVILEGES` so ETL-recreated tables stay readable by `sec_read`.

```bash
git -C ~/p/python_misc/py_misc pull --rebase && git -C ~/p/python_misc/py_misc push
```

**This script lives only in a personal repo — the SEC team will not get it.** Copy it into
`sec_etl/scripts/` (SEC-HANDOFF.md §6.2 references it).

### Failure reporting — how it works

`etl.qmd` runs each script via `runpy.run_path` and reads a module-level `success` back out
of the namespace. Each script's `process()` returns `self.succeeded`; `EtlProcessor.fail()`
records a fatal error. Previously scripts caught and logged exceptions without re-raising, so
**a hard failure was reported as a passing step**.

Verified: all 7 scripts against a dead DB port → `ok=False`; positive control → `ok=True`; and
a probe reproducing the pre-fix code → `ok=True` on the same failure, proving the fix is what
changed it. `docs/failed-email-example.html` is a rendered failing report.

---

## 4. ⚠️ TOP OPEN ITEM — `MIN_EXP_TRIALS` is blocking the NLP steps

`etl.qmd` runs the three NLP steps only if `trials > MIN_EXP_TRIALS` (default **3945**).

| | Count |
|---|---|
| CTS API returns today | **3,904** |
| prod `trials` after 2026-09-15 run | 3,904 |
| prod `trials` before | 3,961 |
| threshold | **3,945** |

The API itself returns 3,904 — this is not a truncated load; the population genuinely shrank
(`record_verification_date_gte` is a rolling 2-year window). **Every nightly run will skip the
NLP steps** until the threshold is lowered, so `ncit_nlp_concepts`, `nlp_data_tab` and
`candidate_criteria` will drift stale against a `trials` table that *is* being rebuilt.

Suggested: **3500** — still catches a genuinely broken load. Set it in Connect's Vars pane on
app `67177a19-…` (no redeploy needed). Local runs need `MIN_EXP_TRIALS=0` in `~/.sec/local.env`.

Current trial count from the CTS API (note `--compressed`; responses are gzipped):

```bash
set -a; . ~/.sec/local.env >/dev/null 2>&1; set +a; TWO_YRS_AGO=$(python3 -c "import datetime;d=datetime.date.today();print(d.replace(year=d.year-2).isoformat())"); curl -s --compressed -X POST "https://clinicaltrialsapi.cancer.gov/api/v2/trials" -H "x-api-key: $CTS_V2_API_KEY" -H "Content-Type: application/json" -d "{\"current_trial_status\":\"Active\",\"primary_purpose\":[\"TREATMENT\",\"SCREENING\"],\"sites.recruitment_status\":\"ACTIVE\",\"size\":1,\"from\":0,\"record_verification_date_gte\":\"$TWO_YRS_AGO\"}" | python3 -c "import sys,json;d=json.load(sys.stdin);print('TOTAL =',d.get('total'))"
```

---

## 5. `api_etl_v2` performance — and how CTF solved it

`api_etl_v2` is **single-threaded** (no `ThreadPoolExecutor`/`asyncio`/`multiprocessing`; the
`requests.Session()` is connection reuse only). Measured on prod: **~98 trials/min ≈ 610 ms
per trial**, ~1 hour for the trial load.

Per trial, `process_trial_record` does **5 `execute()`, 3 `commit()`, 5 loops, and one
`get_maintypes()`** — ~11,900 transaction commits per run. `get_maintypes()` is the dominant
cost: a 4-way join with a `min(level)` CTE, planner cost **~6,973**, against
`ncit_tc_with_path` which has **26,075,619 rows in prod** (~4× the local copy). It dominated
`pg_stat_activity` for the entire trial load.

### CancerTrialsFinder does this properly

Files: `~/p/at/CancerTrialsFinder/backend/etl/runtime/etl_process_db.py` and
`.../database/db_facade.py`.

**The old, slow version is still in `db_facade.py` commented out — and it is SEC's current
query.** CTF evolved past it in four steps:

1. **Materialise the 4-way join once** (`process_disease_to_maintypes`):
   ```sql
   create table parent_descendant_level as
   select distinct np.parent as maintype, np.descendant, np.level
   from ncit_tc_with_path np join maintypes m on np.parent = m.cid
    join ncit n on np.parent = n.code
    join ncit nc on np.descendant = nc.code;
   ```
2. **Materialise the min-level once** (`populate_minlevel`, called from `etl_process_db.py`)
   — the CTE SEC recomputes per trial, precomputed for all codes.
3. **The lookup becomes two small indexed tables:**
   ```sql
   select pdl.maintype from parent_descendant_level pdl
    join minlevel ml on pdl.level = ml.level
    where pdl.descendant = %s and ml.code = %s
   ```
4. **Key by DISEASE, not by trial.** `disease_to_maintypes` is built per distinct disease
   code; `insert_trial_maintypes()` then maps trials → diseases → maintypes **in memory**.
   SEC calls `get_maintypes()` once per trial even though many trials share a lead disease.

Only then is it threaded: `ThreadProcessor(thread_function, count_per_thread=40,
thread_count=25, timeout=420)` over a 35-connection pool, merged under a `threading.Lock`.

This fits CTF's step-function split: `etl_process_db` populates, `etl_make_datasets` consumes.
Maintypes are computed **once, in bulk, up front** — never inside a per-trial loop.

**Recommended order for SEC (threading last):**
1. Materialise `parent_descendant_level` + `minlevel` in `refresh_ncit_pg` — same technique as
   the POC-223 transitive-closure fix (`drop index → bulk insert → recreate index`), which
   took the closure to 30 seconds.
2. Key maintypes by disease, not trial (even an `lru_cache` captures most of this).
3. Commit per page instead of 3× per trial; drop the per-page `select count(*) from trials`.
4. Threading only if 1–3 are insufficient — they probably are sufficient, and the shared
   `con`/`cur` is not thread-safe.

---

## 6. Verification commands

### Connect API (personal API key from your Connect profile)

```bash
read -rs -p "Connect API key: " K && export CONNECT_API_KEY="$K" && echo
```

```bash
curl -s -H "Authorization: Key $CONNECT_API_KEY" "https://posit-connect-prod.cancer.gov/__api__/v1/content/67177a19-f8eb-479e-a7de-bb5d87010bc8/jobs" | python3 -m json.tool | grep -E '"(id|start_time|end_time|exit_code|tag)"' | head -40
```

A healthy full run is **hours**. A **~27-second** `build_report` means steps are disabled —
that is the signature of the March–September 2026 outage.

### Prod database — READ ONLY (VPN required)

> **Never modify prod.** These are `SELECT`s only.

```bash
set -a; . ~/.sec/prod.env >/dev/null 2>&1; set +a; export PGGSSENCMODE=disable; psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER password=$DB_PASS sslmode=prefer" -c "select 'trials' t, count(*) from secapp.trials union all select 'associations', count(*) from secapp.associations union all select 'ncit_nlp_concepts', count(*) from secapp.ncit_nlp_concepts union all select 'nlp_data_tab', count(*) from secapp.nlp_data_tab union all select 'candidate_criteria', count(*) from secapp.candidate_criteria"
```

Is an ETL running right now?

```bash
set -a; . ~/.sec/prod.env >/dev/null 2>&1; set +a; export PGGSSENCMODE=disable; psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER password=$DB_PASS sslmode=prefer" -c "select pid, state, now()-query_start as dur, left(regexp_replace(query,'\s+',' ','g'),70) q from pg_stat_activity where datname='sec' and pid<>pg_backend_pid()"
```

### Failure-detection test (local)

Requires the `3.11.5` venv — the only one with spacy and psycopg2. Exits non-zero if any
script fails to report `success=False` on a dead database.

```bash
/Users/marianom2/p/sec/venvs/3.11.5/bin/python3 ~/p/sec/sec_etl/scripts/test_success.py bad
```

*(The harness was written to a session scratch directory; copy it into `scripts/` to keep it.)*

---

## 7. Reference — state as of 2026-09-16

| Item | Value |
|---|---|
| Prod app GUID | `67177a19-f8eb-479e-a7de-bb5d87010bc8` (numeric id **14**) |
| Prod app name / title | `sec-etl-prod` / `sec_etl` |
| Active bundle | **10815**, created 2026-09-15 16:47:57 |
| Previous bundle | 4506 (2026-03-22) — commit `e909c69`, six `eval: false` |
| Variant | id 1, default, `email_collaborators: true`, `visibility: public` |
| Schedule | daily **18:00** |
| Publish configs | `sec_etl-7J7R.toml` (→ 4E4C), `sec_etl-260126-22PK.toml` (→ TDM9) |
| Entrypoint | `etl.qmd` (both configs) |
| Runtime | Python 3.9.16, Quarto 1.4.557 (bundles report 1.4.551) |
| Prod DB | schema `secapp`, PostgreSQL 16 — see SEC-HANDOFF.md §6.2 |
| `ncit_tc_with_path` (prod) | 26,075,619 rows |

### Open items

1. **Lower `MIN_EXP_TRIALS`** (§4) — NLP steps skipped nightly until then.
2. **Push `py_misc` `a6abf26`** and copy `sec_db_setup.sh` into `sec_etl/scripts/`.
3. **Confirm nightly runs now take hours, not seconds** — check jobs after the next 18:00.
4. Add `.positignore`; gitignore `postgres_data_dir-bkup/` in `sec_poc`.
5. Rotate any API key that sat in an unignored env file.
6. Optimise `api_etl_v2` maintypes per §5.
7. `update_trials_sid()` in `api_etl_v2.py` is defined but never called; it would
   `ALTER TABLE trials ADD COLUMN sid INT`. Its existence check is not schema-qualified,
   which matters in prod where tables live in `secapp`. Decide keep/wire-up/remove.
8. `etl.qmd`'s `_run_script(*args)` accepts positional args but never forwards them, so
   `--force` cannot be plumbed through.
9. Consider retitling the two apps so the Connect listing distinguishes them (§2.1).
