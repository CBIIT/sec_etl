# SEC — Session Handoff (2026-09-23)

Read this first, then:
- [SEC-SESSION-HANDOFF-2026-09-22.md](SEC-SESSION-HANDOFF-2026-09-22.md) — the previous day
- [ETL-DEPLOY-RUNBOOK.md](ETL-DEPLOY-RUNBOOK.md) — Posit publishing, the outage history, CTF maintypes
- [SEC-HANDOFF.md](SEC-HANDOFF.md) — project/environment setup, sec_admin

---

## 1. Live state, verified 2026-09-23 16:32

| Repo | Branch | HEAD | State |
|---|---|---|---|
| `sec_etl` | `main` | `6d04554` | synced |
| `sec_poc` | `master` | `6d4d176` | synced |
| `sec_nlp` | `main` | `0219a67` | synced |
| `py_misc` | `main` | `d754e68` | **ahead 1, still unpushed** |

### Production database

| Table | 09-22 | **09-23** | Reading |
|---|---|---|---|
| `trials` | 3,906 | 3,904 | nightly ETL running |
| `ncit_nlp_concepts` | 2,026,697 | **2,075,276** | ✅ **NLP unblocked** |
| `nlp_data_tab` | 2,026,065 | **2,075,213** | ✅ moved |
| `candidate_criteria` | 102,775 | **103,652** | ✅ moved |
| `disease_tree` | 45,130 | 45,130 | ❌ still stale |
| `disease_tree*` `n_tup_ins` | 0 | **0** | ❌ post-ETL has never completed |

**`MIN_EXP_TRIALS=3850` worked** (set in the Connect Vars pane, no deploy). Six nights of NLP
drift closed. `disease_tree` is the remaining problem.

---

## 2. THE DEPLOY IS STILL PENDING

Everything below is committed and pushed to `main` but **not deployed**. Production still runs
bundle **10815** from 09-15.

Deploy from the VS Code Publisher panel (see §4 for why nobody else can):
1. All three repos on their default branch (versions in §1).
2. **⌘⇧P → `Posit Publisher: Select Deployment`**
3. **Both deployments are titled `sec_etl`.** Pick by **Configuration = `sec_etl-7J7R`**
   (the wrong one is `sec_etl-260126-22PK`). Confirm with
   **⌘⇧P → `Posit Publisher: View Deployment`** — the URL must contain
   `67177a19-f8eb-479e-a7de-bb5d87010bc8`.
4. Vars: `MIN_EXP_TRIALS=3850`, **no `FORCE_*`**.
5. **Never deploy within ~3h of 18:00** — the render *is* a 3-hour ETL and will collide with the
   schedule. Either deploy in the morning or disable the schedule first.
6. ~13 min of "waiting for server" is `python_restore`, not a hang. **Do not retry.**

Proof of success afterwards — this counter is what exposed the six-night outage:

```bash
set -a; . ~/.sec/prod.env >/dev/null 2>&1; set +a; export PGGSSENCMODE=disable; psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER password=$DB_PASS sslmode=prefer" -c "select relname, n_tup_ins, n_tup_del from pg_stat_user_tables where schemaname='secapp' and relname like 'disease_tree%'"
```

`disease_tree.n_tup_ins` leaving **0** is the only thing that proves post-ETL finished.

---

## 3. What is on `main` and not yet deployed

`0b66242` **Make ETL failures visible and stop partial state spreading**

- `zip(statuses, scripts)` truncates silently and `all([])` is True — a chunk dying before its
  `oks.append()` dropped that step *and* could still title the email **ETL PASSED**. Any length
  mismatch is now a failure and prints `REPORT INCOMPLETE`.
- `_trial_count` imported psycopg2 outside its `try`. A missing module escaped the gate chunk,
  leaving `run_nlp`/`gate_reason` undefined, which took the NLP chunks and then the whole report
  down. Import moved inside; gate variables now have defaults defined before the gate chunk.
- **Email prints row counts for 11 tables.** A step can pass while leaving its table frozen —
  exactly how `disease_tree` went six nights unnoticed.
- NLP steps no longer run after an upstream step fails.
- `etl_printer` printed `COMPLETED` from a `finally:`, putting that word directly under every
  traceback. Failures now print `FAILED`.
- **TCP keepalives** on the api_etl_v2 connection (`keepalives=1, idle=30, interval=10, count=5`).
- `union` instead of `union ALL` + a `pd.level < 999` depth cap on **both** disease-tree CTEs.
- Removed a per-page `select count(*) from trials` and the never-called `update_trials_sid`.
- Deleted `etl_post_render.py` (dead; it hardcoded "SEC ETL Pipeline Ran Successfully").

`f289553` / `ed0ea38` **Per-script force flags**

- `FORCE_<SCRIPT>` per script (`api_etl_v2.py` → `FORCE_API_ETL_V2`), plus `FORCE_ALL`.
- No argv plumbing needed: `etl.qmd` runs scripts via `runpy` **in the same process**, so the
  environment reaches them directly. That matters because `--force` is `store_true` and
  `_run_script` builds argv as key/value pairs — `{'--force': True}` emits `--force True`, which
  argparse rejects.
- `force_requested()` **never raises** and returns False for anything unresolvable. It is a parser
  default evaluated at import in all seven scripts; if it raised the script would die.
- The email prints `FORCE FLAGS ACTIVE: …` so a flag left in the Vars pane is visible.

**Only 5 of 7 scripts can act on a force flag.** `api_etl_v2` and `get_associations` have no skip
path, so their flags are accepted and reported but do nothing.
`sec_poc_expression_generator` declared `--force` and never read it — now implemented by clearing
`candidate_criteria.generated_date` (same technique the classifier uses on `classification_date`).

Local files (all gitignored, cannot reach Connect — the publish config is an **allowlist**):
`flags-force.env` (all on), `flags-off.env` (all off), `flags.env` (older duplicate of
flags-force). Tracked template: `flags.env.example`.

---

## 4. Gotchas that cost time this session

1. **Claude cannot deploy.** Verified exhaustively, not assumed: extension `posit.publisher-2.12.0`
   contains only JS (`dist/`, `webviews/`), no `bin/`, no executables, nothing in VS Code
   globalStorage, no `rsconnect-python`, no `publisher` on PATH. Browser automation is blocked for
   `posit-connect-prod.cancer.gov`. **A human must click Deploy.** Do not hand-roll a bundle via
   the REST API — Publisher's `manifest.json` (python version, package set, per-file checksums) is
   precisely the part that would be wrong.
2. **`n_live_tup` LIES.** It reported **0 for all 34 local tables** and 0 for prod `disease_tree`
   (which has 45,130 rows) because the stats collector never ran. **Always use `count(*)`.** This
   caused two wrong conclusions in two days.
3. **The local DB is fully populated** — 3,904 trials, 6.37M `ncit_tc_with_path`, 46,266
   `disease_tree`. **Do not "restore" it.** There is no prod dump; `postgres_data_dir-bkup` is a
   Jan-10 PGDATA snapshot of *local*. Live PGDATA is bound from `~/p/sec/sec_poc/postgres_data_dir`
   (a plain directory, **not** the submodule).
4. **`DB_SCHEMA` is never read by any code.** Local (`public`) vs prod (`secapp`) resolves from the
   default `search_path` of `"$user", public` — user `secapp` finds schema `secapp`. No schema
   translation is needed to run locally.
5. **`api_etl_v2.py` is a REAL FILE at the `sec_etl` root**, the one exception to the symlink
   pattern. `sec_poc/db_api_etl/api_etl_v2.py` is a stale 1,031-line duplicate (2,057 diff lines)
   that is **bundled but never executed** — `_locate_script` prefers the root file. Left alone
   deliberately: it is in both publish `files` lists and changing bundle composition right before a
   prod deploy is runbook §2.7's exact failure mode.
6. **Both Publisher deployments are titled `sec_etl`.** Disambiguate by configuration name or GUID.
7. **`FORCE_*` in Connect Vars persists** — it would force every nightly run indefinitely.
   `FORCE_SEC_POC_CLASSIFIER` alone reclassifies all ~3,900 trials nightly.
8. **VPN/DNS from the Claude sandbox is intermittent.** `ncidb-d606-v.nci.nih.gov` and
   `posit-connect-prod.cancer.gov` sometimes fail to resolve even while the user is on VPN.
9. **Cameron Crouch (`crouchcd`) owns the production app**, not Matt — Matt is a collaborator with
   publish rights. That is why prod never appeared under "My Work" (that tab lists content you
   *own*). **Cameron no longer works here**, so ownership should be reassigned.
   Runbook §2.1's "suspect duplicate titles before permissions" advice is backwards and needs fixing.

---

## 5. Wrong conclusions I reached — do not repeat them

| Claim | Reality |
|---|---|
| "The deployed `api_etl_v2.py` is in no commit" | It is — in `sec_etl` root, `bd58608`. I searched only `sec_poc`. |
| "`union ALL` explosion causes the prod timeout" | **Not supported.** The query runs in **5.6s** locally on near-identical data. |
| "Prod is missing an index" | **Wrong.** Prod has all three (`ncit_tc_path_parent`, `…_descendant`, `dtd_index`). |
| "The local DB is empty" | Wrong — `n_live_tup` lie. |
| "Matt owns the prod app" | Cameron does. `app_role: owner` was read against the *personal* copy. |

---

## 6. ⚠️ The post-ETL failure root cause is STILL UNKNOWN

`process_post_etl` dies at `api_etl_v2.py:620` — the
`create table disease_tree_temp as (with recursive …)` statement — with
`psycopg2.OperationalError: could not receive data from server: Connection timed out`. That is a
socket-level `ETIMEDOUT`, **not** a Postgres error (a statement timeout would read
"canceling statement due to statement timeout").

**Two hypotheses died:**
- Duplicate-path amplification is real (`parent_descendant` 275,370 → 48,344 rows with `union`,
  82% waste) but costs only **1.5 seconds** locally. Not a hang.
- All three indexes exist in prod.

Local is a fair proxy: `trials` 3,904 vs 3,906, `distinct_trial_diseases` 6,239 vs 6,263. The
4.1× difference in `ncit_tc_with_path` total rows is mostly higher-level closure rows the query
never reads (it filters `tc.level = 1`; only 248,643 of 6.37M rows locally qualify).

**Still-live candidates:** the 09-15 collision (two concurrent ETLs contending on
`drop`/`create disease_tree_temp` — the traceback is timestamped `21:11:19`, the tail of exactly
that collided run), or a genuine network/firewall reap.

**Most discriminating unmeasured fact:** the `process_post_etl STARTED` timestamp from the 09-15
log. Job `329109` ran `18:00:53 → 21:11:24`; STARTED gives the exact duration before the timeout
and separates "died in seconds" from "blocked for two hours".

**Decisive read-only probe** (the exact CTE, 5-minute cap, zero write keywords):

```bash
set -a; . ~/.sec/prod.env >/dev/null 2>&1; set +a; export PGGSSENCMODE=disable; psql "host=$DB_HOST port=$DB_PORT dbname=$DB_NAME user=$DB_USER password=$DB_PASS sslmode=prefer" -c "set statement_timeout='5min'" -c "\timing on" -f <scratch>/prod_probe.sql
```

Expect ~275,370 rows in seconds. A timeout reproduces the failure; a fast return means the SQL is
innocent and the cause is the collision or the network.

**Keepalives are the safety net either way** — whatever the cause, they turn a silent reap into
either survival or a fast, clear error, and the row counts in the email make staleness visible the
next morning.

---

## 7. How the changes were verified

- **`scripts/test_report_logic.py`** — drives `etl.qmd`'s own chunks through 4 scenarios
  (all pass / upstream failure / gate skip / a chunk dying), 16 assertions. The 4th now yields
  `FAILED` + `REPORT INCOMPLETE` where it previously produced **`ETL PASSED`**.
- **`scripts/test_force_flags.py`** — resolution, per-script isolation, truthiness, `FORCE_ALL`,
  symlink-vs-target paths, and hostile input (None/int/dict/extensionless) proving no raise.
  Confirmed under `env -i`.
- **The `union` change is output-identical**, proven on the local DB for **both** CTEs:

  | | rows | `EXCEPT ALL` both ways | dupes | time |
  |---|---|---|---|---|
  | `disease_tree_temp` | 46,266 = 46,266 | 0 / 0 | none | 5.59s → 4.12s |
  | `disease_tree_temp_nostage` | 31,958 = 31,958 | 0 / 0 | none | 4.59s → 3.39s |

  Plain `EXCEPT` is **not** sufficient — it dedups, so two different multisets can both return 0.
  `EXCEPT ALL` plus a duplicate-count check is what makes it conclusive.
- Max recursion depth is **15**, so the 999 cap never engages — proven harmless, unproven as a guard.
- SQL was extracted from source **via AST**, not retyped, so "old" was byte-exact.

---

## 8. Open items

1. **Deploy** (§2) — everything is staged and verified; nothing else is blocked on it.
2. **Root-cause post-ETL** (§6) — get the STARTED timestamp; run the probe.
3. **Push `py_misc` `d754e68`** — needs a personal access token:
   ```bash
   git -C ~/p/python_misc/py_misc push
   ```
   It carries `sec_db_setup.sh`, which the SEC team cannot otherwise get. Copy it into
   `sec_etl/scripts/`.
4. **Reassign the prod app owner** — Cameron has left.
5. **Retitle the two `sec_etl` apps** so the Connect listing and Publisher picker differ.
6. **Resolve the duplicate `api_etl_v2.py`** (symlink or delete + update both publish configs) —
   after a deploy, not before.
7. **Deferred perf work** (runbook §5): `lru_cache` on `get_maintypes`, commit-per-page,
   materialise `parent_descendant_level`/`minlevel` CTF-style. Deliberately kept out of this deploy.
8. `Status` class in `api_etl_v2.py` is now unreferenced (was only used by `update_trials_sid`).
9. Rotate any API key that sat in an unignored env file (runbook open item #5).

---

## 9. Unrelated AT work done in this session

A message intended for another chat landed here and was completed: the GA4 **SSM → hardcoded**
change for FORGE2-TF. Details are in `~/Documents/AT/handoffs/at-handoff-2026-09-23.md`.
Two findings worth carrying: **SpatialPower was never SSM-injected for gtag**, and the
"SSM parameters" in the FORGE2/Spatial **2.0.0** release notes are CDK infrastructure parameters
that remain correct — do not "fix" them.
