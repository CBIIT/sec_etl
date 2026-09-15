# inits the dates that are checked before a setp is run
docker exec -e PGPASSWORD=sec sec_pg5433 psql -U sec -d sec -v ON_ERROR_STOP=1 <<'SQL'
UPDATE trial_nlp_dates SET tokenized_date = NULL, classification_date = NULL;
UPDATE candidate_criteria SET generated_date = NULL;
UPDATE ncit_version SET ncit_tokenizer = NULL WHERE active_version = 'Y';
UPDATE ncit_version SET version_id = 'force-rerun' WHERE active_version = 'Y';
SQL
cd ~/p/sec/sec_etl && set -a && . ./bad-local.env && set +a && export QUARTO_PYTHON=~/p/sec/venvs/3.11.5/bin/python PGGSSENCMODE=disable && quarto render etl.qmd