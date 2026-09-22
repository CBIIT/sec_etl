"""Verify per-script force flags resolve from the environment."""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from etl_processor import force_env_name, force_requested, active_force_flags

SCRIPTS = ['refresh_ncit_pg.py','nlp_tokenizer.py','api_etl_v2.py','get_associations.py',
           'sec_poc_tokenizer.py','sec_poc_classifier.py','sec_poc_expression_generator.py']
ok = True
def check(label, got, want):
    global ok
    if got != want: ok = False
    print(f"  [{'ok ' if got==want else 'FAIL'}] {label}: {got!r} (want {want!r})")

for k in list(os.environ):
    if k.startswith('FORCE_'): del os.environ[k]

print("=== nothing set -> nothing forced")
for s in SCRIPTS: check(force_env_name(s), force_requested(s), False)
check('active_force_flags', active_force_flags(SCRIPTS), [])

print("\n=== each flag forces only its own script")
for target in SCRIPTS:
    os.environ[force_env_name(target)] = '1'
    for s in SCRIPTS: check(f"{force_env_name(target)} set -> {s}", force_requested(s), s == target)
    del os.environ[force_env_name(target)]

print("\n=== truthiness")
for val, want in [('1',True),('true',True),('TRUE',True),('yes',True),('on',True),(' y ',True),
                  ('0',False),('false',False),('off',False),('no',False),('',False)]:
    os.environ['FORCE_API_ETL_V2'] = val
    check(f"FORCE_API_ETL_V2={val!r}", force_requested('api_etl_v2.py'), want)
del os.environ['FORCE_API_ETL_V2']

print("\n=== FORCE_ALL forces everything")
os.environ['FORCE_ALL'] = '1'
for s in SCRIPTS: check(f"FORCE_ALL -> {s}", force_requested(s), True)
check('active includes FORCE_ALL', 'FORCE_ALL' in active_force_flags(SCRIPTS), True)
del os.environ['FORCE_ALL']

print("\n=== path form does not matter (symlink vs target)")
check('abs path', force_requested('/a/b/sec_nlp/sec_poc_classifier.py'), False)
os.environ['FORCE_SEC_POC_CLASSIFIER'] = '1'
check('abs path forced', force_requested('/a/b/sec_nlp/sec_poc_classifier.py'), True)

print("\nRESULT:", "ALL PASS" if ok else "FAILURES PRESENT")
sys.exit(0 if ok else 1)
