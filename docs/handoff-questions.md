# SEC — Open Questions

Things that need a human decision or a fact I could not establish. Companion to
[SEC-SESSION-HANDOFF-2026-09-23.md](SEC-SESSION-HANDOFF-2026-09-23.md) — that file records what
*is*; this one records what is *undecided*. Last updated 2026-09-23.

---

## A. Blocking / do soon

### A1. Is the 18:00 schedule still disabled?
It was turned off for the 2026-09-23 deploy, which then failed on Restore Environment. **If it is
still off, production is not running the nightly ETL at all.** Re-enable it as soon as the deploy
lands, or immediately if the deploy slips.
→ *This is the highest-risk open item on the page.*

### A2. Why does `process_post_etl` time out?
Still unknown after two hypotheses died (see handoff §6). `disease_tree` has not been rebuilt once
— `n_tup_ins` is still **0**.

Two cheap things settle it:
- The **`process_post_etl STARTED`** timestamp from the 09-15 Connect log. Job `329109` ran
  `18:00:53 → 21:11:24`; STARTED separates "died in seconds" from "blocked for two hours", which
  point at completely different causes.
- The read-only CTE probe against prod (handoff §6). ~275,370 rows in seconds means the SQL is
  innocent and the cause is the 09-15 collision or the network.

**Do not assume the keepalives fixed it.** They convert a silent reap into a loud failure; they are
not a proven cure.

### A3. Who owns the production Connect app now?
`67177a19-…` is owned by **Cameron Crouch (`crouchcd`), who no longer works here.** Matt is a
collaborator with publish rights. Consequences: prod never appears under Matt's "My Work"; the
schedule, access list and title are nominally Cameron's; and a departed owner is a bus-factor and
possibly an access-review problem.
**Question: reassign to Matt, or to a team/service account?** A service account is the better
answer if one exists.

---

## B. Deployment / environment

### B1. Should the Python pin be corrected to what Connect actually runs?
`sec_etl-7J7R.toml` requests `version = '3.9.16'`. Connect evidently does not have it and selects a
newer interpreter — the 09-15 traceback shows **py3.12**. That mismatch is what turned
`blis==0.7.8` (no wheel above cp310) into a source build and got the restore OOM-killed.

The blis bump to 0.7.11 fixes the symptom. **But the pin is still fiction**, and the next package
without a cp312 wheel will do the same thing.
**Question: pin to the interpreter Connect actually provides, and how do we discover what that is?**
`GET /__api__/v1/server_settings/python` with an API key answers it.

### B2. Can the restore memory limit be raised?
Exit 137 was the OOM killer. Even with wheels, a future dependency could compile. **Is there a
per-content or server-level memory setting for the restore step**, and who can change it?

### B3. Should the duplicate `api_etl_v2.py` be removed?
`sec_etl/api_etl_v2.py` (1,086 lines) is the real, executed file. `sec_poc/db_api_etl/api_etl_v2.py`
(1,031 lines, 2,057 diff lines) is stale, **bundled but never executed** — `_locate_script` prefers
the root file. It already caused one wrong diagnosis.

Left alone deliberately: it is listed in **both** publish configs' `files`, and changing bundle
composition right before a prod deploy is runbook §2.7's exact failure mode.
**Question: delete (and update both configs), or symlink it to the root file?** Symlink is safer —
it keeps both configs and `sec_poc/scripts/etl_script.sh` working. **Do it after a successful
deploy, not before.** Note the refactored root file needs `etl_processor.py`, which `sec_poc` does
not have, so a naive symlink breaks `etl_script.sh`.

### B4. Should the two `sec_etl` apps be retitled?
Both are titled `sec_etl` on posit-connect-prod and in the Publisher picker, distinguishable only
by configuration name (`sec_etl-7J7R` vs `sec_etl-260126-22PK`) or GUID. This is the single most
likely cause of a wrong-app deploy — and a deploy is a 3-hour production ETL.
Retitling renames production content, so it needs a deliberate decision.

---

## C. Design decisions deferred

### C1. Should the run-metadata table be reconsidered?
Proposed and declined. The substitute shipped — **row counts for 11 tables in the report email** —
makes staleness visible to a human the next morning, but it is not queryable and the app itself
still cannot tell whether its data is fresh. Given `disease_tree` went six nights unnoticed,
worth revisiting.

### C2. Is email alone an adequate alert?
The failure email went out every morning for six nights and nothing happened. **Question: should
failures escalate somewhere else** (Teams, a ticket, a pager)?

### C3. When does the deferred performance work get scheduled?
Kept out of the current deploy on purpose (runbook §5). In payoff order:
1. `lru_cache` on `get_maintypes()` keyed by disease code — many trials share a lead disease, and
   each call is a ~6,973-cost plan against a 26M-row table.
2. Commit per page instead of 3× per trial (~11,900 commits per run today).
3. Materialise `parent_descendant_level` + `minlevel` once, CTF-style.
4. Threading **last** — the shared `con`/`cur` is not thread-safe.

Current throughput: ~98 trials/min ≈ 610 ms/trial, about an hour for the trial load.

### C4. Should `update_trials_sid()` come back?
Removed as dead code (never called). It mirrored CTF's `simple_id` derivation and would
`ALTER TABLE trials ADD COLUMN sid INT`. Its column check was **not schema-qualified**, which
matters in prod where tables live in `secapp`. Recoverable from history.
**Question: was it a half-finished feature someone wants, or genuinely abandoned?**

### C5. `Status` class is now unreferenced
`api_etl_v2.py` still defines it; its only consumer was `update_trials_sid`. Remove or keep?

### C6. Should `MIN_EXP_TRIALS` track the live CTS count?
Currently a hardcoded floor of 3850 against ~3,904 trials — roughly 1.4% headroom. The CTS
population drifts (it was 3,961, then 3,904) because `record_verification_date_gte` is a rolling
two-year window. **A fixed floor will eventually close the gate again**, silently, exactly as it
did for six nights. A relative check (e.g. "no more than N% below last successful run") would be
self-maintaining.

---

## D. Smaller / housekeeping

- **`py_misc` `d754e68` is still unpushed** — needs a personal access token. It carries
  `sec_db_setup.sh`, which the SEC team cannot otherwise get. Should it also be copied into
  `sec_etl/scripts/`?
- **Rotate any API key** that sat in an unignored env file (runbook open item #5). Was this done?
- **`_run_script(*args)`** accepts positional args and never forwards them, so `--force` cannot be
  plumbed that way. Now moot for force (env vars handle it) — remove the dead parameter?
- **Runbook §2.1 is wrong** — it says to suspect duplicate titles before permissions. The real
  reason prod was "missing" from My Work is that **My Work lists only content you own**. Fix the text.
- **`.positignore`** — concluded unnecessary, since the publish config is an explicit allowlist and
  the 1.9 GB `postgres_data_dir-bkup` is never bundled. Confirm nobody is relying on the opposite.

---

## E. Cross-project (AT, not SEC)

- **COMETS Explorer** (NCIATWP-10385, `G-Q8TQYQTE61`) is now the **only** SSM-injected GA4 app after
  FORGE2-TF moved to a hardcoded ID. Its `GA4-SSM-deploy-step` doc and release notes still specify
  `put-parameter`. **Same change, or leave it?**
- **Does the GA4 hostname Data Filter actually exist?** The whole "same real ID in every tier"
  gating model depends on it, and it was recorded as unverified. Now that FORGE2-TF hardcodes a
  real prod ID in **every** tier, non-prod traffic pollutes prod reporting if that filter is absent.
