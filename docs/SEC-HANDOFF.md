# SEC POC — Handoff: VS Code + Posit Connect Deployment Setup

Handoff documentation for the **SEC POC** (Structured Eligibility Criteria Proof of Concept) project.
Covers the source repositories, the Posit Connect deployment targets, and the VS Code
(Posit Publisher) configuration used to deploy each component.

> **Secrets:** This document lists environment-variable **names only**. No passwords or API-key
> values are recorded here. Values live in the Posit Connect content **Vars/Secrets** panel per
> deployment, and locally in `~/.sec/*.env` (not committed). Obtain them from the outgoing
> developer or the Connect admins.

---

## 1. At a glance

| Component | What it is | Connect server | Entrypoint |
|---|---|---|---|
| **sec_poc** | R/Shiny end-user UI | appshare‑dev | `app.R` |
| **sec_admin** | R/Shiny admin dashboard (shinymanager auth) | appshare‑dev | `app.R` |
| **sec_etl** | Quarto ETL job + email report | **posit‑connect‑prod** | `etl.qmd` |
| **ctsapi_for_public_use** | Streamlit demo (inside sec_poc repo) | appshare‑dev | `demos/ctsapi_for_public_use/app.py` |

Two Connect servers are in play:

- **Appshare (treated as Dev)** — [https://appshare-dev.cancer.gov/](https://appshare-dev.cancer.gov/)
  Hosts the UI apps. Not 24×7: it shuts down around **5–6pm ET** daily and has fewer resources.
- **Posit Connect Prod** — [https://posit-connect-prod.cancer.gov/](https://posit-connect-prod.cancer.gov/)
  Hosts the **sec_etl** scheduled job, because the ETL must run outside Appshare's hours.

**All access requires NIH VPN.**

---

## 2. Source repositories

Local working root: `~/p/sec`

| Repo | GitHub | Local path | Branch |
|---|---|---|---|
| sec_etl | [CBIIT/sec_etl](https://github.com/CBIIT/sec_etl) | `~/p/sec/sec_etl` | `main` |
| sec_admin | [CBIIT/sec_admin](https://github.com/CBIIT/sec_admin) | `~/p/sec/sec_admin` | `master` |
| sec_poc | [CBIIT/sec_poc](https://github.com/CBIIT/sec_poc) | submodule of sec_etl | see below |
| sec_nlp | [CBIIT/sec_nlp](https://github.com/CBIIT/sec_nlp) | submodule of sec_etl | `main` |

### 2.1 Submodules (important)

`sec_etl` contains **two git submodules** (`.gitmodules`):

```
[submodule "sec_nlp"]  path = sec_nlp  url = https://github.com/CBIIT/sec_nlp  ignore = untracked
[submodule "sec_poc"]  path = sec_poc  url = https://github.com/CBIIT/sec_poc  ignore = untracked
```

Clone with submodules:

```bash
git clone --recurse-submodules https://github.com/CBIIT/sec_etl.git
# or, in an existing clone:
git submodule update --init --recursive
```

The ETL scripts at the **top level of `sec_etl` are symlinks** into the submodules:

| Symlink in `sec_etl/` | Real file |
|---|---|
| `refresh_ncit_pg.py`, `nlp_tokenizer.py`, `get_associations.py` | `sec_poc/db_api_etl/…` |
| `sec_poc_tokenizer.py`, `sec_poc_classifier.py`, `sec_poc_expression_generator.py`, `common_funcs.py`, `create_performance_expression.py` | `sec_nlp/…` |
| `api_etl_v2.py`, `etl_processor.py` | real files in `sec_etl/` |

Because they are symlinks, the Publisher `files` list must include **both** the symlink and its
real target (see §4.3) or the bundle will be missing code.

---

## 3. Posit Connect deployment targets

All GUIDs, dashboard/log URLs and access panels. These are the values recorded in each repo's
`.posit/publish/deployments/*.toml`.

### 3.1 sec_poc (Appshare / Dev)

| Field | Value |
|---|---|
| Config name | `sec_poc-QK8U` |
| Deployment record | `.posit/publish/deployments/deployment-INA0.toml` |
| Server | `https://appshare-dev.cancer.gov` |
| Content GUID | `6fe04d08-5df3-465e-b6c8-961d7812213f` |
| Type | `r-shiny` · entrypoint `app.R` |
| Last deployed | 2025‑10‑15 |

- Dashboard: [open](https://appshare-dev.cancer.gov/connect/#/apps/6fe04d08-5df3-465e-b6c8-961d7812213f)
- Direct URL: [open](https://appshare-dev.cancer.gov/sec_poc/)
- Logs: [open](https://appshare-dev.cancer.gov/connect/#/apps/6fe04d08-5df3-465e-b6c8-961d7812213f/logs)
- Access: [open](https://appshare-dev.cancer.gov/connect/#/apps/6fe04d08-5df3-465e-b6c8-961d7812213f/access)

### 3.2 sec_admin (Appshare / Dev)

| Field | Value |
|---|---|
| Config name | `sec_admin-BVPI` |
| Deployment record | `.posit/publish/deployments/deployment-1LQI.toml` |
| Server | `https://appshare-dev.cancer.gov` |
| Content GUID | `4a00bf2a-7468-4c37-9c65-8e33dd561c0c` |
| Type | `r-shiny` · entrypoint `app.R` |
| Last deployed | 2026‑03‑22 |

- Dashboard: [open](https://appshare-dev.cancer.gov/connect/#/apps/4a00bf2a-7468-4c37-9c65-8e33dd561c0c)
- Logs: [open](https://appshare-dev.cancer.gov/connect/#/apps/4a00bf2a-7468-4c37-9c65-8e33dd561c0c/logs)
- Access: [open](https://appshare-dev.cancer.gov/connect/#/apps/4a00bf2a-7468-4c37-9c65-8e33dd561c0c/access)

### 3.3 sec_etl (Posit Connect **Prod**)

There are **two** deployment records pointing at prod. Only the first is current — see the
warning below.

**Current / correct — `7J7R`:**

| Field | Value |
|---|---|
| Config name | `sec_etl-7J7R` |
| Deployment record | `.posit/publish/deployments/deployment-4E4C.toml` |
| Server | `https://posit-connect-prod.cancer.gov` |
| Content GUID | `67177a19-f8eb-479e-a7de-bb5d87010bc8` |
| Type | `quarto-static` · entrypoint `etl.qmd` |
| Last deployed | 2026‑03‑22 (bundle 4506) |

- Dashboard: [open](https://posit-connect-prod.cancer.gov/connect/#/apps/67177a19-f8eb-479e-a7de-bb5d87010bc8)
- Direct URL: [open](https://posit-connect-prod.cancer.gov/content/67177a19-f8eb-479e-a7de-bb5d87010bc8/)
- Logs: [open](https://posit-connect-prod.cancer.gov/connect/#/apps/67177a19-f8eb-479e-a7de-bb5d87010bc8/logs)

**Stray duplicate — `22PK` (do not deploy to this):**

| Field | Value |
|---|---|
| Config name | `sec_etl-260126-22PK` |
| Deployment record | `.posit/publish/deployments/deployment-TDM9.toml` |
| Content GUID | `ee78cbdc-81e0-43ef-a353-9b1c1f750d2b` |
| Last deployed | 2026‑01‑27 (bundle 2294) |

- Dashboard: [open](https://posit-connect-prod.cancer.gov/connect/#/apps/ee78cbdc-81e0-43ef-a353-9b1c1f750d2b)

> ⚠️ **Deploy gotcha.** `22PK` was created accidentally by selecting "new deployment" instead of
> the existing one. When deploying sec_etl in Posit Publisher, **always select `sec_etl-7J7R`**.
> Choosing the wrong entry creates a *second* piece of content on prod rather than updating the
> scheduled job. If you see a new untracked `.posit/publish/deployments/deployment-*.toml` appear
> after deploying, you picked the wrong target — check `git status` / the git graph.

### 3.4 ctsapi_for_public_use (Appshare / Dev)

| Field | Value |
|---|---|
| Config name | `ctsapi_for_public_use-FMV4` |
| Deployment record | `.posit/publish/deployments/deployment-2VBJ.toml` |
| Server | `https://appshare-dev.cancer.gov` |
| Content GUID | `5c166cef-768e-4f21-9faf-5ec22fa089e2` |
| Type | `python-streamlit` · entrypoint `demos/ctsapi_for_public_use/app.py` |
| Last deployed | 2025‑08‑06 |

- Dashboard: [open](https://appshare-dev.cancer.gov/connect/#/apps/5c166cef-768e-4f21-9faf-5ec22fa089e2)

---

## 4. Posit Publisher configuration (per project)

Config files live in `<repo>/.posit/publish/<name>.toml`; deployment records (auto-generated,
**do not hand-edit**) live in `<repo>/.posit/publish/deployments/<name>.toml`.

### 4.1 Runtime / environment

| Project | Type | Entrypoint | Runtime | Package file |
|---|---|---|---|---|
| sec_poc | `r-shiny` | `app.R` | R **4.5.1** (`renv.lock`) | `renv.lock` |
| sec_admin | `r-shiny` | `app.R` | R **4.5.1** (`renv.lock`) | `renv.lock` |
| sec_etl | `quarto-static` | `etl.qmd` | Python **3.9.16** + Quarto **1.4.557** | `requirements.txt` (pip) |
| ctsapi_for_public_use | `python-streamlit` | `demos/ctsapi_for_public_use/app.py` | Python **3.9.16** | `demos/ctsapi_for_public_use/requirements.txt` (pip) |

### 4.2 Declared secrets (names only)

These are declared in the `secrets = [...]` key of each config and **must be populated in the
Connect content's Vars panel** after the first deploy.

| Project | Secrets |
|---|---|
| sec_poc | `BING_MAPS_API_KEY`, `CTS_V2_API_KEY`, `DB_HOST`, `DB_NAME`, `DB_PASS`, `DB_PORT`, `DB_USER`, `UMLS_API_KEY` |
| sec_admin | `DB_HOST`, `DB_NAME`, `DB_PASS`, `DB_PORT`, `DB_USER`, `USERS_DB_PASS` |
| sec_etl | `CTS_V2_API_KEY`, `DB_HOST`, `DB_NAME`, `DB_PASS`, `DB_PORT`, `DB_USER` |
| ctsapi_for_public_use | `CTS_V2_API_KEY` |

`USERS_DB_PASS` is the passphrase that decrypts sec_admin's shinymanager SQLite user database.

### 4.3 sec_etl bundled files

The `files` list in `sec_etl-7J7R.toml` includes the entrypoint, `requirements.txt`, the two
`.posit` files, **and both the symlinks and their real targets**:

```
/etl.qmd, /requirements.txt,
/refresh_ncit_pg.py, /nlp_tokenizer.py, /get_associations.py, /api_etl_v2.py,
/common_funcs.py, /create_performance_expression.py,
/sec_poc_classifier.py, /sec_poc_expression_generator.py, /sec_poc_tokenizer.py,
/sec_poc/db_api_etl/{api_etl_v2,get_associations,refresh_ncit_pg,nlp_tokenizer}.py,
/sec_nlp/{common_funcs,create_performance_expression,sec_poc_classifier,
          sec_poc_expression_generator,sec_poc_tokenizer}.py
```

> **Note — `etl.qmd` vs `etl-new.qmd`.** The deployed entrypoint is **`etl.qmd`**.
> A newer `etl-new.qmd` exists in the repo (refactored report that renders the ETL logs into
> `email-preview/index.html` via `format: email`) but it is **not referenced by any Publisher
> config** and is therefore not deployed. If the new report is meant to replace the old one,
> the entrypoint and `files` list in `sec_etl-7J7R.toml` must be updated.

### 4.4 sec_admin — `localdb/users.sqlite` ships with every deploy

`sec_admin-BVPI.toml` explicitly includes `/localdb/users.sqlite` in `files` (and *excludes*
`init_user_db.R` / `migrate_user_db.R`). Confirmed present in the last deployment bundle.

> ⚠️ **The deployed SQLite user DB is overwritten on every publish.** Users added through the
> running dashboard's shinymanager admin panel live only on the server copy. **Before deploying,
> download the latest `users.sqlite` from the admin dashboard** into `sec_admin/localdb/` and
> commit it. If you forget, use Connect's **rollback** to recover the previous bundle's file.
> (Migrating shinymanager from SQLite to PostgreSQL is recommended — see sec_admin commit
> `c30bbc5` as a starting point.)

---

## 5. VS Code setup

### 5.1 Extensions

| Extension | ID | Needed for |
|---|---|---|
| **Posit Publisher** | `posit.publisher` | All deployments (this is the deploy UI) |
| R | `reditorsupport.r` | sec_poc / sec_admin (recommended in `.vscode/extensions.json`) |
| R Debugger | `rdebugger.r-debugger` | sec_poc / sec_admin |

Posit Publisher docs: [posit-dev/publisher](https://github.com/posit-dev/publisher) ·
configuration reference: [configuration.md](https://github.com/posit-dev/publisher/blob/main/docs/configuration.md) ·
VS Code usage: [vscode.md](https://github.com/posit-dev/publisher/blob/main/docs/vscode.md)

> Posit Publisher is **not** listed in the repos' `.vscode/extensions.json` recommendations —
> install it manually.

### 5.2 Prerequisites

1. **NIH VPN** — required for both Connect servers and the prod database.
2. **Publisher access** on the target Connect server. Request from the Appshare admins:
   **George Zaki, Guillermo Choy‑Leon, Raymond Kobe**.
3. **A Connect API key** — create under your profile in Connect
   ([API keys docs](https://docs.posit.co/connect/user/api-keys/)). Posit Publisher prompts for
   the server URL + API key when you add a credential.
4. Open each repo as its **own VS Code workspace** (recommended by the sec_poc README).

### 5.3 One-time setup on a new machine (do this first)

The `.posit/` config files **are committed in the repos**, but the *credential* (server + API key)
is stored locally in VS Code and is **not** in the repo. Every new developer must create their own.

1. Connect to **NIH VPN**.
2. Install the **Posit Publisher** extension (`posit.publisher`).
3. Get a **Connect account + publisher rights** on the target server (§5.2). Confirm you can log
   in to the server's web UI before continuing.
4. In Connect's web UI, create an **API key**: your avatar → *API Keys* → *+ New API Key* → copy it
   (shown once). [API keys docs](https://docs.posit.co/connect/user/api-keys/)
5. Clone the repo **with submodules** (§2.1) and open it as its own VS Code workspace.
6. Open the **Posit Publisher** view from the VS Code Activity Bar.
7. Add a credential: in the Publisher panel choose to add/manage credentials, then supply
   - **Server URL** — `https://appshare-dev.cancer.gov` for the apps, or
     `https://posit-connect-prod.cancer.gov` for sec_etl
   - **API key** — from step 4
   - a **nickname** (e.g. `appshare-dev`, `connect-prod`)

   You will need **both** credentials eventually, since sec_etl targets a different server than
   the UI apps.

### 5.4 First deployment

There are two different situations. **Read §5.4.1 first** — for a team takeover it is almost
always the right one, because it keeps the existing content GUIDs and URLs.

#### 5.4.1 Option A — take over the EXISTING Connect content (recommended)

The repos already contain deployment records (`.posit/publish/deployments/*.toml`) that hold the
content GUIDs listed in §3. If your Connect account has rights to those content items, Publisher
will **update them in place** — same GUID, same URL, no migration for end users.

1. **Prerequisite:** your Connect account must be an **owner or collaborator** on the target
   content — publisher rights on the server alone are *not* enough to update someone else's
   content. Ask the current owner (or an admin, §8) to add you as a **Collaborator** on that
   content's Access panel (§3 links). Without this, the deploy fails with a permissions error.
2. Open the repo in VS Code with the Publisher panel open.
3. Publisher lists the deployments found in `.posit/publish/deployments/`. **Select the existing
   one for that project:**
   - sec_poc → `sec_poc-QK8U`
   - sec_admin → `sec_admin-BVPI` (download `users.sqlite` first — §4.4)
   - sec_etl → **`sec_etl-7J7R`** (⚠️ *not* `22PK` — §3.3)
   - ctsapi demo → `ctsapi_for_public_use-FMV4`
4. Confirm the **credential/server** shown matches §3 for that project
   (Appshare for the apps, **posit‑connect‑prod for sec_etl**).
5. Click **Deploy**.
6. Go to §5.5 — the secrets are almost certainly **not** set for your account's view of the
   content; verify them.

#### 5.4.2 Option B — create BRAND-NEW content

Use this only if you are standing the project up on a different Connect server/tier, or you
cannot be granted collaborator rights on the existing content. This produces a **new GUID and a
new URL**, and the old content keeps running until someone retires it.

1. In the Publisher panel, create a **new deployment** (the `+` / "Add Deployment" action).
2. Publisher will prompt for:
   - **Entrypoint** — `app.R` (sec_poc, sec_admin), `etl.qmd` (sec_etl),
     `demos/ctsapi_for_public_use/app.py` (ctsapi demo)
   - **Content type** — usually auto-detected; must match §4.1
     (`r-shiny`, `quarto-static`, `python-streamlit`)
   - **Credential** — the server you added in §5.3
   - **Configuration name** and **Title**
3. Publisher writes two files:
   - `.posit/publish/<config-name>.toml` — the config (entrypoint, files, secrets, runtime)
   - `.posit/publish/deployments/deployment-XXXX.toml` — the record (gets the new GUID after
     the first successful deploy)
4. **Before deploying, copy the `files` and `secrets` lists from the existing config** for that
   project (§4.2, §4.3) into your new config. This matters most for **sec_etl**, whose `files`
   list must include both the symlinks and their real targets (§4.3), and **sec_admin**, which
   must include `/localdb/users.sqlite` (§4.4). A default file list will miss these and the
   deploy will be broken.
5. Click **Deploy**. On success the new GUID is written into the deployment record.
6. Complete §5.5 (secrets/access/schedule) — a brand-new content item has **none** of it.
7. **Commit the new `.posit` files** and update §3 of this document with the new GUIDs/URLs.

### 5.5 Required post-first-deploy configuration (in the Connect web UI)

A first deploy is **not finished** until these are done. The code deploys, but nothing works
without them.

1. **Set the environment variables / secrets.** The `secrets = [...]` in the config only declares
   the *names*; **values are never uploaded**. In the content's settings go to the **Vars**
   panel and add every variable listed for that project in §4.2, with values from `~/.sec`
   (§6.1) or your own environment. Missing `DB_*` is the single most common cause of a
   "deployed but broken" app.
2. **Set Access** — content's *Access* panel (links in §3): sharing mode plus the users/groups
   who may view it. Users must already exist on the Connect server (first NIH SSO login or admin
   provisioning) before they can be added.
3. **sec_etl only — set the schedule.** It is a scheduled Quarto job, not an interactive app.
   In the content settings configure the run **schedule** and the **email** recipients
   (the report is rendered as an email via Quarto's `format: email`, and Connect sends it on each
   scheduled run).
4. **sec_admin only** — the shinymanager users live in the bundled `localdb/users.sqlite`
   (§4.4). Confirm you can log in, and read §4.4 before your *next* deploy.
5. **Confirm the runtimes exist on the server** — R **4.5.1**, Python **3.9.16**, Quarto
   **1.4.557** (§4.1). If the target server lacks a matching runtime the deploy or start-up
   fails; ask the Connect admins (§8) to install it.

### 5.6 Subsequent deploys (second time onward)

Once §5.3–5.5 are done, routine deploys are short:

1. VPN on; open the repo in VS Code.
2. **sec_admin only:** download the current `users.sqlite` from the running dashboard into
   `sec_admin/localdb/` first, or you will wipe live users (§4.4).
3. In the Publisher panel **select the existing deployment** — never create a new one:
   `sec_poc-QK8U` · `sec_admin-BVPI` · **`sec_etl-7J7R`** · `ctsapi_for_public_use-FMV4`.
4. Verify the credential/server is correct for that project.
5. Click **Deploy**.
6. Verify via the content's **Logs** URL (§3). For sec_etl the job runs the full ETL on deploy
   (allow ~1–1.5 h — §6.3).
7. `git status` — **if a new `deployment-*.toml` appeared, you deployed to the wrong target**
   and just created a second piece of content. Delete the stray file, remove the accidental
   content in Connect, and redeploy against the correct deployment (this is exactly how the
   `22PK` duplicate in §3.3 came to exist).

Secrets/access/schedule persist on the content across redeploys — you only set them once (§5.5),
unless you add a new variable to `secrets`.

---

## 6. Local development environment

### 6.1 Environment variables — `~/.sec`

Convention: files named **`local*`** hold the LOCAL DB connection; files named **`prod*`** hold
the PROD connection (VPN required).

- `~/.sec/local.env`, `~/.sec/local-with-prefix-LOCAL.env`, `~/.sec/local-exports-with-prefix-LOCAL.sh`
- `~/.sec/prod.env`, `~/.sec/prod-with-prefix-PROD.env`, `~/.sec/prod-exports-with-prefix-prod.sh`
- `~/p/sec/source_these_exports.sh` sources both and exports the **LOCAL** values as the active
  `DB_*` (while taking `USERS_DB_PASS` from the prod set for shinymanager).

Variables: `DB_NAME`, `DB_SCHEMA`, `DB_USER`, `DB_PASS`, `DB_HOST`, `DB_HOST_FOR_R`, `DB_PORT`,
`USERS_DB_PASS`, `CTS_V2_API_KEY`, `UMLS_API_KEY`, `BING_MAPS_API_KEY`.

### 6.2 Databases

| | Host | Port | DB | Schema | User |
|---|---|---|---|---|---|
| **Local** | localhost | 5433 | sec | `public` | sec |
| **Prod** | `ncidb-d606-v.nci.nih.gov` | 5439 | sec | **`secapp`** | secapp |

Prod is **PostgreSQL 16** (the 5439 port is *not* Redshift). Other prod schemas: `umls` (19
tables), `fhirops` (10), `testdata` (5), `fhir_etl` (4). The sec_poc UI reads `fhirops.*` and
`umls.*` tables; the ETL only needs `secapp`.

**Running the local DB.** The `sec_poc/postgres_data_dir` cluster was `initdb`'d on Linux with
`LC_COLLATE 'en_US.utf8'`, which current macOS Postgres rejects
(*"database locale is incompatible with operating system"*). Run it as a Linux container
(equivalent to `sec_poc/docker/R/r_n_pg2/docker-compose.yaml`):

```bash
docker run -d --name sec_pg5433 \
  -e POSTGRES_DB=sec -e POSTGRES_USER=sec -e POSTGRES_PASSWORD=sec \
  -p 5433:5432 \
  -v ~/p/sec/sec_poc/postgres_data_dir:/var/lib/postgresql/data \
  postgres:17
```

Use `PGGSSENCMODE=disable` for psql clients to avoid a GSSAPI negotiation error.

**Rebuilding the local schema from prod (structure only, read-only on prod):**

```bash
pg_dump -h ncidb-d606-v.nci.nih.gov -p 5439 -U secapp -d sec \
  --schema-only --schema=secapp --no-owner --no-privileges --no-tablespaces \
  -f prod_secapp_ddl.sql
sed -e 's/secapp\./public./g' -e '/^CREATE SCHEMA secapp;/d' prod_secapp_ddl.sql | \
  docker exec -i -e PGPASSWORD=sec sec_pg5433 psql -U sec -d sec -v ON_ERROR_STOP=1
```

Yields 34 tables + 4 views in local `public`. Then run the ETL to populate. The local DB also
needs a `sec_read` role (`CREATE ROLE sec_read;`) — `get_associations.py` issues
`GRANT SELECT ON associations TO sec_read`, which exists in prod but not by default locally.

### 6.3 Running the ETL locally

```bash
cd ~/p/sec/sec_etl
set -a; . ~/.sec/local.env; set +a
export QUARTO_PYTHON=~/p/sec/venvs/3.11.5/bin/python PGGSSENCMODE=disable
quarto render etl.qmd     # or etl-new.qmd for the newer report
```

A full run takes roughly **1–1.5 hours** (NCIT thesaurus load + ~6.4M-row transitive closure +
~3,900 trials + spaCy NLP + expression generation). The `sec_poc_expression_generator` ontology
pass is the dominant cost (~50 min) and is the first place to optimize.

---

## 7. Operational notes & known issues

- **Appshare is a Dev tier** — not 24×7, shuts down ~5–6pm ET, fewer resources. This is why the
  ETL lives on posit‑connect‑prod.
- **ETL failure mode:** the daily ETL email's errors are *almost always* caused by a newly
  published **NCI Thesaurus version**. Cancer Trials Finder (CTF) has a fix for this that was
  never ported over.
- **ETL dashboard visibility:** the sec_etl Connect dashboard historically showed only a
  spinner with no stdout. `etl_processor.py` now writes each step as a flushed line to
  `etl_output/<script>.txt`, and the newer `etl-new.qmd` renders those logs into the email —
  but see §4.3, that report is not yet the deployed entrypoint.
- **`process_transitive_closure`** in `refresh_ncit_pg.py` has previously been left uncalled,
  which silently leaves codes out of `ncit_tc_with_path` (e.g. `C225003`). Verify it runs after
  any refactor. The closure needs a well-placed index to perform.
- **sec_poc UI** has no in-app login — Connect access *is* the gate. **sec_admin** has a second
  gate: shinymanager credentials in `users.sqlite` (§4.4).
- Backups referenced by sec_admin: `s3://sec-poc-archive/` (e.g. `shinymanager-sql-*.sqlite`).

---

## 8. Access & contacts

| Purpose | Who / where |
|---|---|
| Appshare (Connect) publisher access & accounts | George Zaki, Guillermo Choy‑Leon, Raymond Kobe |
| Connect content access (per app) | The `/access` panel on each content item (§3) |
| FHIR non-prod access | NCI ServiceNow ticket for `NIH.NCI.CBIIT.FHIR.NONPROD` |
| Prior developer (original author) | Cameron Crouch |

Users must exist on the Connect server (first NIH SSO login, or admin provisioning) **before**
they can be added to a content item's Access list.

---

*Prepared for the SEC POC team transition.*
