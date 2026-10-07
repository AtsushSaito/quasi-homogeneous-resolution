#!/usr/bin/env python3
"""Aggregate results/summary.tsv: verdict counts by family, external-expectation matches, A4 / nondeg rates."""
import csv, collections, sys
rows = list(csv.DictReader(open('results/summary.tsv'), delimiter='\t'))
byfam = collections.defaultdict(collections.Counter)
ext = collections.defaultdict(collections.Counter)
a4 = collections.defaultdict(lambda: [0, 0]); nd = collections.defaultdict(lambda: [0, 0])
for r in rows:
    fam = r['family']; byfam[fam][r['verdict']] += 1
    if r.get('ext', '-') != '-': ext[fam][r['ext'].split('(')[0]] += 1
    key = (fam, r['p'])
    a4[key][1] += 1
    if r['A4'] == 'true':
        a4[key][0] += 1
        nd[key][1] += 1
        if r['nondeg'] == 'true': nd[key][0] += 1
print('verdicts by family:')
for fam in sorted(byfam): print(' ', fam, dict(byfam[fam]), ' ext:', dict(ext[fam]) if ext[fam] else '')
print('\nA4 rate and Newton non-degeneracy rate (among A4) by family and p:')
for key in sorted(a4):
    n_ok, n_all = a4[key]; d_ok, d_all = nd[key]
    print(f'  {key[0]} p={key[1]}: A4 {n_ok}/{n_all}   nondeg {d_ok}/{d_all}')
mis = [r for r in rows if r['verdict'] in ('MISMATCH', 'TORIC-FAIL', 'CRASH', 'TIMEOUT/ERROR') or r.get('ext','').startswith('EXT-MISMATCH')]
print('\nsamples needing attention:', len(mis))
for r in mis: print('  ', r['name'], r['verdict'], r.get('ext',''), r.get('notes','')[:150])
