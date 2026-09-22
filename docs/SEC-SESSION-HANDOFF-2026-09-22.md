# SEC — Session Handoff (2026-09-22)

Written before a context compact. Read this first, then:

- [ETL-DEPLOY-RUNBOOK.md](ETL-DEPLOY-RUNBOOK.md) — **the full history, gotchas and analyses**
  (Posit publishing pitfalls, the production outage, CTF maintypes comparison, verification
  commands). Everything below assumes it.
- [SEC-HANDOFF.md](SEC-HANDOFF.md) — project/environment setup, deploy checklists, sec_admin.

---

## 1. Live state, verified 2026-09-22

### Repos

| Repo | Branch | HEAD | State |
|---|---|---|---|
| `sec_etl` | `main` | `fea9456` | synced; **1 uncommitted file** (below) |
| `sec_nlp` | `main` | `8c193aa` | synced, clean |
| `sec_poc` | `master` | `fc75320` | synced, clean |
| `py_misc` | `main` | `d754e68` | **ahead 1 — UNPUSHED** |

### Production database (read-only check)

| Table | 2026-09-16 | **2026-09-22** | Reading |
|---|---|---|---|
| `trials` | 3,904 | **3,906** | nightly ETL IS running and reloading trials |
| `associations` | 6,924 | 6,924 | healthy (repaired by the 09-15 deploy) |
| `ncit_nlp_concepts` | 2,026,697 | **2,026,697** | **unchanged — NLP steps skipped** |
| `nlp_data_tab` | 2,026,065 | **2,026,065** | **unchanged** |
| `candidate_criteria` | 102,775 | **102,775** | **unchanged** |

---

## 2. ⚠️ TOP ITEM — `MIN_EXP_TRIALS` has been skipping the NLP steps for a week

The threshold was never lowered. `trials = 3,906` against a floor of **3,945**, so the gate
closes every night:

```
3906 <= MIN_EXP_TRIALS (3945)  ->  sec_poc_tokenizer, sec_poc_classifier,
                                    sec_poc_expression_generator all SKIPPED
```

**Six consecutive nightly runs have rebuilt `trials` while leaving the NLP tables frozen.**
The three NLP tables are byte-identical to their 09-16 values — that is the proof. The data is
drifting: trials change nightly, the NLP/criteria/expression tables derived from them do not.

This is the gate working as designed; it simply cannot distinguish "the API broke" from "the
corpus is genuinely smaller now". The CTS API itself returns 3,904–3,906, so this is the real
population, not a truncated load.

**Fix (no redeploy needed):** set `MIN_EXP_TRIALS` in the Connect **Vars** pane on the
production app. Suggested value **3500** — still catches a genuinely broken load.

```
https://posit-connect-prod.cancer.gov/connect/#/apps/67177a19-f8eb-479e-a7de-bb5d87010bc8
```

Verify the current API count first (note `--compressed`; responses are gzipped):

```bash
set -a; . ~/.sec/local.env >/dev/null 2>&1; set +a; TWO_YRS_AGO=$(python3 -c "import datetime;d=datetime.date.today();print(d.replace(year=d.year-2).isoformat())"); curl -s --compressed -X POST "https://clinicaltrialsapi.cancer.gov/api/v2/trials" -H "x-api-key: $CTS_V2_API_KEY" -H "Content-Type: application/json" -d "{\"current_trial_status\":\"Active\",\"primary_purpose\":[\"TREATMENT\",\"SCREENING\"],\"sites.recruitment_status\":\"ACTIVE\",\"size\":1,\"from\":0,\"record_verification_date_gte\":\"$TWO_YRS_AGO\"}" | python3 -c "import sys,json;d=json.load(sys.stdin);print('TOTAL =',d.get('total'))"
```

After changing it, confirm the next 18:00 run actually rebuilt the NLP tables — the counts in
§1 must move.

---

## 3. Outstanding, small

### 3.1 `sec_etl` — uncommitted deployment record

Posit Publisher rewrote `.posit/publish/deployments/deployment-4E4C.toml` during the 09-15
deploy and it was never committed:

```
- client_version = '1.36.0'          + client_version = "2.8.0"
- deployed_at = '2026-03-22…'        + deployed_at = "2026-09-15T22:24:09.868Z"
- bundle_id = '4506'                 + bundle_id = "10815"
```

Machine-generated (quote style changed too, hence 268 changed lines). Commit it so the record
matches what is actually deployed.

### 3.2 `py_misc` — still unpushed

`d754e68` (`matt/bin/sec_db_setup.sh` rewrite) has never pushed; the remote needs a credential
that can't be supplied non-interactively (it wants a personal access token, not a password).

```bash
git -C ~/p/python_misc/py_misc push
```

**That script lives only in a personal repo — the SEC team will not get it.** Copy it into
`sec_etl/scripts/`; SEC-HANDOFF.md §6.2 references it.

---

## 4. Access request — the four new SEC POC users

NED lookups, all verified unique in the directory:

| Name | NED name | **NIH Login Username** | Email |
|---|---|---|---|
| Matt Fischer | Fischer, Matthew Carl | `fischermc` | matt.fischer@nih.gov |
| Joslin Sheridan | Sheridan, Joslin Helena | `sheridanjh` | joslin.sheridan@nih.gov |
| Bill Dyer | Dyer, William T, Jr | `dyerwt` | — |
| Anna Fernandez | — | *(looked up earlier)* | — |

Semicolon-delimited for an email To: line:

```
anna.fernandez@nih.gov; matt.fischer@nih.gov; joslin.sheridan@nih.gov; bill.dyer@nih.gov
```

**Status / gotchas:**
- At lookup time, searching Appshare/Connect for `Fischer` returned nothing while `Zaki`
  returned George Zaki — the four were **not yet provisioned as Connect users**. They must log
  into Appshare once before they can be added to a content access list.
- Bill Dyer and Anna Fernandez were added to Access on both SEC POC and SEC Admin.
- **sec_admin needs a second step:** Connect access only reaches the shinymanager login
  screen. They also need credentials in the encrypted `localdb/users.sqlite` — see
  SEC-HANDOFF.md §4.4.

---

## 5. sec_admin `users.sqlite` — already documented, don't rediscover it

SEC-HANDOFF.md covers this in six places (§4.2 line 189, §4.4, §5.4 line 299, §5.5 line 329,
§5.6 lines 352/363, §7 lines 533–534). The essentials:

> **The deployed SQLite user DB is overwritten on every publish.** Users added through the
> running dashboard's shinymanager admin panel live only on the server copy. **Before
> deploying, download the latest `users.sqlite` from the admin dashboard** into
> `sec_admin/localdb/` and commit it. If you forget, use Connect's **rollback**.

`sec_admin-BVPI.toml` explicitly includes `/localdb/users.sqlite` and excludes
`init_user_db.R` / `migrate_user_db.R`. Backups: `s3://sec-poc-archive/`
(`shinymanager-sql-*.sqlite`). Long-term fix: migrate shinymanager to PostgreSQL —
sec_admin commit `c30bbc5` is a starting point.

**Not cross-referenced from ETL-DEPLOY-RUNBOOK.md** — someone treating that as "the Posit
deploy doc" could deploy sec_admin without seeing the warning. Worth a one-line pointer.

---

## 6. The five things most likely to bite next time

1. **Two apps are titled `sec_etl`** on posit-connect-prod and are indistinguishable in the
   listing. Production is `67177a19-…` (numeric id 14, name `sec-etl-prod`, daily 18:00
   schedule, emails collaborators). The other, `ee78cbdc-…`, is a personal copy. A bundle
   downloaded from the wrong one caused a completely wrong diagnosis for hours.
2. **Deploying sec_etl runs the whole ETL** (3+ hours, against prod). Never deploy near 18:00 —
   on 09-15 the scheduled run overlapped the deploy render by 2h 09m, two ETLs writing the same
   tables.
3. **"Waiting for server" is normal** — it was 13.5 minutes of `python_restore`. Do not retry.
4. **A ~27-second `build_report` job means steps are disabled.** That was the signature of the
   March–September 2026 outage, when six of seven steps carried `eval: false` and prod was a
   nightly no-op. Check job durations, not just exit codes.
5. **Deploys must be done by a human in VS Code** — no `publisher` CLI exists here, and browser
   automation is blocked for that domain. Use the Connect REST API with a personal API key for
   inspection (runbook §6).

---

## 7. Analyses worth not repeating

- **`api_etl_v2` is single-threaded and slow for structural reasons** — ~98 trials/min
  (~610 ms/trial): one `get_maintypes()` per trial (planner cost ~6,973 against a
  26,075,619-row `ncit_tc_with_path` in prod) plus 3 commits per trial (~11,900 per run).
  **CancerTrialsFinder solved exactly this** by materialising `parent_descendant_level` and
  `minlevel` once, keying maintypes by *disease* rather than trial, and only then threading.
  Full comparison with file references in runbook §5. Fix order: materialise → key by disease →
  commit per page → threading last.
- **The refactor preserved logic**, verified by AST comparison rather than reading diffs: SQL
  literal multisets unchanged, five `re.VERBOSE` regexes byte-identical, stopword lists
  identical including duplicates, and the `nlp_tokenizer` zip-iterator quirk kept verbatim.
- **Failure reporting is tested.** `etl.qmd` reads a module-level `success` back out of
  `runpy.run_path`. All 7 scripts report `ok=False` against a dead DB; a probe of the pre-fix
  code reports `ok=True` on the same failure, proving the fix is what changed it.
  `docs/failed-email-example.html` is a rendered failing report.
