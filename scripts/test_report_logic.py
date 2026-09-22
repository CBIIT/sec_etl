"""Drive etl.qmd's own report logic through four scenarios. No real scripts."""
import io, re, sys, contextlib
from pathlib import Path

QMD = Path('/Users/marianom2/p/sec/sec_etl/etl.qmd')
SKIP = {'spacy-download', 'remove-old-email-preview'}

def chunks():
    out, text = [], QMD.read_text()
    for m in re.finditer(r'```\{python\}\n(.*?)```', text, re.S):
        body = m.group(1)
        lab = re.search(r'#\|\s*label:\s*(\S+)', body)
        label = lab.group(1) if lab else '(none)'
        if label in SKIP:
            continue
        out.append((label, re.sub(r'^#\|.*$', '', body, flags=re.M)))
    return out

def run(scenario, fail_step=None, trial_count=99999, drop_chunk=None):
    ns = {'__name__': '__main__'}
    buf = io.StringIO()
    for label, code in chunks():
        if label == drop_chunk:
            continue                       # simulate a chunk dying before append
        if label == 'define-helpers':
            with contextlib.redirect_stdout(buf):
                exec(code, ns)
            ns['_run_script'] = lambda n, *a, **k: (
                (False, f'{n} reported success=False') if n == fail_step
                else (True, f'{n} reported success=True'))
            ns['_trial_count'] = lambda: trial_count
            ns['_table_counts'] = lambda: [('trials', 3904), ('disease_tree', 46266)]
            continue
        with contextlib.redirect_stdout(buf):
            exec(code, ns)
    out = buf.getvalue()
    title = 'PASSED' if '<h1>ETL PASSED</h1>' in out else (
            'FAILED' if '<h1>ETL FAILED</h1>' in out else '??')
    return {
        'scenario': scenario, 'title': title,
        'oks': len(ns.get('oks', [])), 'statuses': len(ns.get('statuses', [])),
        'incomplete': 'REPORT INCOMPLETE' in out,
        'nlp': 'ran' if ns.get('run_nlp') else 'SKIPPED',
        'gate': ns.get('gate_reason', ''), 'out': out,
    }

results = [
    run('1 all pass'),
    run('2 api_etl_v2 fails', fail_step='api_etl_v2.py'),
    run('3 gate skip (low count)', trial_count=100),
    run('4 a chunk dies', drop_chunk='run-get_associations'),
]
ok = True
for r in results:
    print(f"\n--- {r['scenario']}")
    print(f"    title={r['title']}  oks={r['oks']} statuses={r['statuses']}"
          f"  incomplete={r['incomplete']}  NLP={r['nlp']}")
    print(f"    gate: {r['gate'][:90]}")

exp = [('1 all pass','PASSED',7,False,'ran'),
       ('2 api_etl_v2 fails','FAILED',7,False,'SKIPPED'),
       ('3 gate skip (low count)','PASSED',7,False,'SKIPPED'),
       ('4 a chunk dies','FAILED',6,True,'ran')]
print("\n=== assertions")
for r,(s,t,n,inc,nlp) in zip(results, exp):
    for name,got,want in (('title',r['title'],t),('oks',r['oks'],n),
                          ('incomplete',r['incomplete'],inc),('nlp',r['nlp'],nlp)):
        flag = 'ok ' if got==want else 'FAIL'
        if got!=want: ok=False
        print(f"  [{flag}] {s}: {name}={got!r} (want {want!r})")
print("\nRESULT:", "ALL PASS" if ok else "FAILURES PRESENT")
sys.exit(0 if ok else 1)
