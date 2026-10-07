#!/usr/bin/env python3
"""Consistency checks of the catalog tables and of the recorded corpus run (no Macaulay2 needed).

  python3 -I tests/catalog/check_catalog.py     (about 1 s)

 * hypersurfaces.tsv lists exactly the samples of results/summary.tsv, with the same verdict
 * results/summary.tsv: 440 rows, the verdict counts are the ones quoted in the README, no row with
   verdict MISMATCH / TORIC-FAIL / PREDICT-FAIL / CRASH
 * every row marked evidence L has verdict EXT-MATCH in summary.tsv; every V row has a certificate file
 * cyclic.tsv: each Hirzebruch-Jung expansion is recomputed (exact integers) and re-evaluated to r/q
 * the recorded certificates: scripts/verify_cofactors.py and scripts/projectivity_exact.py
"""
import csv, os, subprocess, sys
from collections import Counter
from fractions import Fraction
from math import gcd

here = os.path.dirname(os.path.abspath(__file__))
root = os.path.dirname(os.path.dirname(here))
fails = []
def check(cond, msg):
    if not cond: fails.append(msg)

summ = list(csv.DictReader(open(os.path.join(root, 'results/summary.tsv')), delimiter='\t'))
cat = list(csv.DictReader(open(os.path.join(here, 'hypersurfaces.tsv')), delimiter='\t'))

c = Counter(r['verdict'] for r in summ)
check(len(summ) == 440, f'summary.tsv has {len(summ)} rows, expected 440')
check(c['CONFIRM'] == 361 and c['SKIP'] == 79, f'verdict counts {dict(c)}; the README quotes 361 CONFIRM / 79 SKIP')
for bad in ('MISMATCH', 'TORIC-FAIL', 'PREDICT-FAIL', 'CRASH', 'TIMEOUT/ERROR'):
    check(c[bad] == 0, f'{c[bad]} rows with verdict {bad}')
check(all(r['verdict'] != 'SKIP' or r['A4'] == 'false' for r in summ), 'a SKIP row with A4 true')
check(not any(r['ext'].startswith('EXT-MISMATCH') for r in summ), 'an external expectation is violated')

sm = {r['name']: r for r in summ}
check([r['id'] for r in cat] and set(r['id'] for r in cat) == set(sm), 'hypersurfaces.tsv and summary.tsv list different samples')
check(len(cat) == len(set(r['id'] for r in cat)), 'duplicate ids in hypersurfaces.tsv')
for r in cat:
    s = sm.get(r['id'])
    if not s: continue
    check(r['expected_verdict'] == s['verdict'], f"{r['id']}: verdict differs from summary.tsv")
    check(set(r['evidence']) <= set('LXVON'), f"{r['id']}: bad evidence code {r['evidence']}")
    if 'L' in r['evidence']: check(s['ext'] == 'EXT-MATCH', f"{r['id']}: evidence L without EXT-MATCH")
    if 'N' in r['evidence']: check(r['expected_verdict'] == 'SKIP', f"{r['id']}: evidence N on a non-SKIP row")
    if 'V' in r['evidence']: check(os.path.exists(os.path.join(root, r['certificate'])), f"{r['id']}: certificate missing")
    check(r['tier'] in ('ci', 'heavy'), f"{r['id']}: bad tier")
check(sum(1 for r in cat if r['tier'] == 'ci') >= 60, 'fewer than 60 rows in the ci tier')
check(all(any(r['category'] == k and r['tier'] == 'ci' for r in cat) for k in set(r['category'] for r in cat)),
      'a category without a ci row')

def hj(r, q):
    out = []
    while q:
        b = -(-r // q); out.append(b); r, q = q, b * q - r
    return out
for r in csv.DictReader(open(os.path.join(here, 'cyclic.tsv')), delimiter='\t'):
    rr, qq = int(r['r']), int(r['q'])
    bs = [int(t) for t in r['expected_hj'].strip('{}').split(',')]
    check(gcd(rr, qq) == 1 and bs == hj(rr, qq), f"{r['id']}: expected_hj is not the HJ expansion")
    x = Fraction(bs[-1])
    for b in reversed(bs[:-1]): x = b - 1 / x
    check(x == Fraction(rr, qq), f"{r['id']}: expansion does not evaluate to r/q")
    check(int(r['expected_curves']) == len(bs), f"{r['id']}: curve count")

for script in ('scripts/verify_cofactors.py', 'scripts/projectivity_exact.py'):
    p = subprocess.run([sys.executable, '-I', os.path.join(root, script)], cwd=root, capture_output=True, text=True)
    last = p.stdout.strip().splitlines()[-1] if p.stdout.strip() else ''
    print(f'{script}: {last}')
    check(p.returncode == 0, f'{script} exited with status {p.returncode}')
    check('0 not projective, 0 errors' in last if 'projectivity' in script else 'OK' in last, f'{script}: unexpected summary line')

if fails:
    print('FAILED:'); [print('  ' + f) for f in fails]; sys.exit(1)
print(f'catalog consistency OK: {len(cat)} hypersurface rows ({sum(1 for r in cat if r["tier"]=="ci")} ci), '
      f'verdicts {dict(c)}')
