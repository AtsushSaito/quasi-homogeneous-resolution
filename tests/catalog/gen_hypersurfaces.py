#!/usr/bin/env python3
"""Build tests/catalog/hypersurfaces.tsv from results/summary.tsv (observed values of the corpus run)
and the corpus definitions (python3 / M2: scripts/dump_corpus.m2 > corpus.tsv).

  python3 tests/catalog/gen_hypersurfaces.py CORPUS_TSV

Every sample of the corpus is written; the column `tier` marks the representative subset that the
fast runner executes (`ci`).  Nothing is invented here: the expected values are the values recorded
in results/summary.tsv, and the column `evidence` says how far each of them is supported:

  L  the value agrees with a classical value stored in src/corpus.m2 (dual graph of a rational double
     point, invariants of a simple elliptic singularity); verdict EXT-MATCH in summary.tsv
  X  the two routes inside this repository agree (value predicted from the local types at the
     stabiliser strata by qhPredict vs. value computed from the explicit toric resolution)
  V  an independent certificate exists in data/certificates (exact properness test, unit-ideal
     identities re-verified by scripts/verify_cofactors.py)
  O  output of the implementation only
  N  negative case: hypothesis (A4) fails, checked directly with a Jacobian computation
"""
import csv, os, re, sys

here = os.path.dirname(os.path.abspath(__file__))
root = os.path.dirname(os.path.dirname(here))
summ = {r['name']: r for r in csv.DictReader(open(os.path.join(root, 'results/summary.tsv')), delimiter='\t')}
cor = {r['name']: r for r in csv.DictReader(open(sys.argv[1]), delimiter='\t')}
certs = {f[:-4] for f in os.listdir(os.path.join(root, 'data/certificates'))
         if f.endswith('.txt') and f.count('.') == 1}

CI = """A1_p2_w1n1 A2_p3_w1n1 A3_p5_w1n1 A5_p2_w1n1 A6_p7_w1n1 A7_p3_w1n1 A5_p2_whh1 A9_p3_whh1
D4_p3 D5_p5 D6_p3 D8_p3 D40_p2 D60_p2 D50_p2 D70_p2
E6_p3 E60_p2 E7_p2 E7_p3 E8_p2 E8_p3 E8_p5
BP222_p5 BP223_p3 BP234_p2 BP245_p5 BP255_p3 BP333_p2 BP444_p3 BP357_p3
E12_p3 E13_p5 E14_p3 Z11_p2 Z12_p5 W12_p5 W12_p2 Q10_p3 Q11_p7 Q12_p3 S11_p3 S12_p5 U12_p2 U12_p3
Et6_p2 Et6_p3 Et6_p5 Et7_p3 Et7_p2 Et8_p5 Et8_p2
BP2223_p3 BP2224_p3 BP2226_p3 BP2223_p2 BP2333_p3 BP2334_p5 BP3333_p5 BP2225_p7
dim3mixed_p3 nwf2221_p2 nwf2221_p3 nwf2221_p5 curvemu3_p3
dim4mixed_p3 BP22226_p3 BP22223_p5 surfmu3_p3
BP222223_p5 BP222224_p7 dim5mu3_p3 dim6_p5 dim6mu2_p3""".split()

def weights(s): return [int(t) for t in re.findall(r'-?\d+', s)]

def category(n, fam, tags):
    if fam == 'C1': return 'S1 rational double points (surfaces)'
    if fam == 'C2': return 'S2 Brieskorn-Pham surfaces'
    if fam == 'C3': return 'S3 Arnold exceptional unimodal surfaces'
    if fam == 'C4': return 'S4 simple elliptic surfaces'
    if fam == 'C5': return 'H3 threefolds'
    if fam == 'C6': return 'H4 fourfolds'
    return 'H5 dimensions 5 and 6'

def source(n, fam, tags, ev):
    if fam == 'C1':
        s = 'ADE dual graph of a rational double point (classical); '
        if '0_p2' in n or n.startswith('E60'): s += 'equation of Artin char-2 type 0-form, Artin 1977 / Matsumoto Table 1 (not re-read)'
        else: s += 'equation: standard quasi-homogeneous normal form (identification with the Artin type taken from the literature, not re-read)'
        return s
    if fam == 'C4': return 'simple elliptic singularity (classical invariants: genus 1, self-intersection -3,-2,-1 for E~6,E~7,E~8)'
    if fam == 'C3': return 'Arnold exceptional unimodal normal form (weights recomputed here)'
    if fam == 'C2': return 'Brieskorn-Pham x^a+y^b+z^c'
    return 'constructed here (Brieskorn-Pham type or mixed example)'

out = []
for n, c in cor.items():
    s = summ[n]
    p = int(c['p']); w = weights(c['w']); d = s['d']
    verdict = s['verdict']
    fam = c['family']
    ev = ''
    if verdict == 'SKIP':
        ev = 'N'
    else:
        if s['ext'] == 'EXT-MATCH': ev += 'L'
        elif s['armsObs'] not in ('-', ''): ev += 'X'
        else: ev += 'O'
        if n in certs: ev += 'V'
    strata = re.findall(r'\d+', s['strata']) if s['strata'] not in ('-', '') else []
    flags = []
    if any(wi % p == 0 for wi in w): flags.append('p|w_i')
    if d not in ('-', '') and int(d) % p == 0: flags.append('p|d')
    if any(int(r) % p == 0 for r in strata): flags.append('p|r')
    if 'alt weights' in c['tags']: flags.append('alt weights')
    if 'non-well-formed' in c['tags']: flags.append('non-well-formed')
    arms = s['armsObs']
    cert = ('data/certificates/%s.txt' % n) if n in certs else '-'
    tier = 'ci' if n in CI else 'heavy'
    out.append([n, category(n, fam, c['tags']), p, len(w), c['f'], '{' + ', '.join(map(str, w)) + '}', d,
                ';'.join(flags) or '-', verdict, s['strata'], s['nCurvesObs'], arms, s['centreSelf'], s['genusPred'],
                ev, source(n, fam, c['tags'], ev), cert, tier, s['seconds']])
cols = ['id', 'category', 'p', 'n_vars', 'equation', 'weights', 'degree', 'features', 'expected_verdict',
        'expected_strata_orders', 'expected_curves', 'expected_arms', 'expected_centre_self', 'expected_genus',
        'evidence', 'source', 'certificate', 'tier', 'seconds_when_recorded']
missing = [n for n in CI if n not in cor]
assert not missing, missing
with open(os.path.join(here, 'hypersurfaces.tsv'), 'w') as f:
    f.write('\t'.join(cols) + '\n')
    for r in out: f.write('\t'.join(map(str, r)) + '\n')
print(len(out), 'rows,', sum(1 for r in out if r[-2] == 'ci'), 'ci')
