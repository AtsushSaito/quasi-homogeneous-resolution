#!/usr/bin/env python3
"""Generate a Markdown summary of the computational evidence from results/summary.tsv and, if present, results/random_p*.txt (written by scripts/random_search.m2)."""
import csv, collections, glob, re
rows = list(csv.DictReader(open('results/summary.tsv'), delimiter='\t'))
fam_names = {'C1': 'Artin RDP (quasi-homogeneous forms)', 'C2': 'Brieskorn-Pham surfaces (d <= 60)', 'C3': 'Arnold exceptional unimodal (surfaces)',
             'C4': 'simple elliptic', 'C5': 'threefolds', 'C6': 'fourfolds'}
out = []
out.append('| family | samples | CONFIRM | SKIP (A4 fails) | TORIC-FAIL | MISMATCH | other | matches classical value |')
out.append('|---|---|---|---|---|---|---|---|')
for fam in sorted(fam_names):
    rs = [r for r in rows if r['family'] == fam]
    if not rs: continue
    c = collections.Counter(r['verdict'] for r in rs)
    ext = collections.Counter(r['ext'].split('(')[0] for r in rs if r['ext'] not in ('-', ''))
    other = len(rs) - c['CONFIRM'] - c['SKIP'] - c['TORIC-FAIL'] - c['MISMATCH']
    extstr = f"{ext.get('EXT-MATCH',0)}/{sum(ext.values())}" if ext else '—'
    out.append(f"| {fam} {fam_names[fam]} | {len(rs)} | {c['CONFIRM']} | {c['SKIP']} | {c['TORIC-FAIL']} | {c['MISMATCH']} | {other} | {extstr} |")
out.append('')
out.append('Rate of (A4) (isolatedness) and, among the (A4) samples, rate of Newton non-degeneracy, by family and p:')
out.append('')
out.append('| family | p | (A4) holds / samples | Newton non-degenerate / (A4) holds |')
out.append('|---|---|---|---|')
for fam in sorted(fam_names):
    for p in ['2', '3', '5', '7']:
        rs = [r for r in rows if r['family'] == fam and r['p'] == p]
        if not rs: continue
        a4 = [r for r in rs if r['A4'] == 'true']
        nd = [r for r in a4 if r['nondeg'] == 'true']
        out.append(f'| {fam} | {p} | {len(a4)} / {len(rs)} | {len(nd)} / {len(a4)} |')
out.append('')
# random search
out.append('Random search (C9, n = 3, weights <= 5, d <= 15, f with (A4) that are non-convenient or Newton-degenerate):')
out.append('')
out.append('| p | tried | (A4) holds | candidates | CONFIRM | TORIC-FAIL | MISMATCH | ERROR |')
out.append('|---|---|---|---|---|---|---|---|')
for fn in sorted(glob.glob('results/random_p*.txt')):
    txt = open(fn).read()
    m = re.search(r'p = (\d+): tried (\d+), A4 = (\d+), A4 & \(non-convenient or degenerate\) = (\d+)', txt)
    if not m: continue
    res = collections.Counter(line.split('\t')[7] for line in txt.splitlines() if line.startswith('C9RESULT'))
    out.append(f"| {m.group(1)} | {m.group(2)} | {m.group(3)} | {m.group(4)} | {res['CONFIRM']} | {res['TORIC-FAIL']} | {res['MISMATCH']} | {res['ERROR']} |")
out.append('')
bad = [r for r in rows if r['verdict'] not in ('CONFIRM', 'SKIP') or r['ext'].startswith('EXT-MISMATCH')]
out.append(f'Samples needing attention (not CONFIRM/SKIP, or differing from the classical value): {len(bad)}')
for r in bad: out.append(f"- {r['name']}: {r['verdict']} {r['ext']} {r['notes'][:160]}")
print('\n'.join(out))
