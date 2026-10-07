#!/usr/bin/env python3
"""SUPERSEDED by scripts/projectivity_exact.py.  Kept only as a record of the first approach.

This script searches in floating point and then verifies exactly, so a failure here means the
search gave up, not that the fan is non-projective -- it could not settle E_8.  The exact rational
simplex in projectivity_exact.py decides the question either way and should be used instead.

It writes to *.projectivity-float.txt so that running it can never overwrite an exact certificate.

Prove that pi: T -> A^n is PROJECTIVE by exhibiting a strictly concave support function.

A toric morphism from a refinement of the orthant is projective exactly when the refinement is
regular, i.e. when there are heights a_v on the rays such that phi(x) = min_sigma <m_sigma, x>
(m_sigma interpolating a on the maximal cone sigma) is strictly concave: <m_sigma, v> > a_v for
every maximal cone sigma and every ray v not in sigma.

Heights are searched for with a relaxation method in floating point, then rounded to rationals and
VERIFIED EXACTLY with Fraction arithmetic.  Only the exact verification is part of the proof; how
the heights were found does not matter.
"""
import sys, glob, ast
from fractions import Fraction

def inv_unimodular(M):
    """exact inverse of an integer matrix with determinant +-1, as Fractions"""
    n = len(M)
    A = [[Fraction(M[i][j]) for j in range(n)] + [Fraction(int(i == j)) for j in range(n)] for i in range(n)]
    for c in range(n):
        piv = next(r for r in range(c, n) if A[r][c] != 0)
        A[c], A[piv] = A[piv], A[c]
        pv = A[c][c]
        A[c] = [x / pv for x in A[c]]
        for r in range(n):
            if r != c and A[r][c] != 0:
                f = A[r][c]
                A[r] = [x - f * y for x, y in zip(A[r], A[c])]
    return [row[n:] for row in A]

def build(rays, cones):
    """constraint rows r with  r . a >= 1  required, a indexed by ray"""
    n = len(rays[0]); N = len(rays)
    rows = []
    for sig in cones:
        V = [rays[i] for i in sig]                     # rows = rays of sigma
        Vi = inv_unimodular(V)                         # m_sigma = Vi . a_sigma
        for v_idx in range(N):
            if v_idx in sig: continue
            v = rays[v_idx]
            # <m_sigma, v> = v . Vi . a_sigma
            coef = [sum(Fraction(v[k]) * Vi[k][j] for k in range(n)) for j in range(n)]
            row = [Fraction(0)] * N
            for j, i in enumerate(sig): row[i] += coef[j]
            row[v_idx] -= 1
            rows.append((row, sig, v_idx))
    return rows

def wallrows(rows, cones):
    """keep only the constraints coming from a pair of maximal cones sharing a wall"""
    n = len(cones[0]); out = []
    for row, sig, v in rows:
        tau = [i for i in sig]
        # (sig, v) is a wall constraint iff some facet of sig together with v spans a maximal cone
        for k in range(len(sig)):
            face = sorted(sig[:k] + sig[k+1:])
            if sorted(face + [v]) in [sorted(c) for c in cones]:
                out.append((row, sig, v)); break
    return out

def solve(rows, N, basis, iters=200000, start=None):
    a = list(start) if start else [0.0] * N
    fr = [[float(x) for x in r] for r, _, _ in rows]
    nrm = [sum(x * x for x in r) or 1.0 for r in fr]
    for sweep in range(iters):
        moved = False
        for k, r in enumerate(fr):                       # cyclic relaxation, cheap per step
            s = sum(x * y for x, y in zip(r, a))
            if s < 1.0 - 1e-9:
                moved = True
                step = 1.6 * (1.0 - s) / nrm[k]
                for i in range(N):
                    if i not in basis and r[i]: a[i] += step * r[i]
        if not moved: return a
    return None

def run(path):
    txt = open(path).read().strip().splitlines()
    rays = ast.literal_eval(txt[0].replace('{', '[').replace('}', ']'))
    cones = ast.literal_eval(txt[1].replace('{', '[').replace('}', ']'))
    n = len(rays[0]); N = len(rays)
    basis = {i for i, r in enumerate(rays) if sum(r) == 1 and max(r) == 1}
    rows = build(rays, cones)
    # a good starting point: the support function of the weighted blow-up itself, phi_0(x) =
    # min_i x_i / w_i, with the added rays pushed below it so the refinement can appear.
    w = next((r for r in rays if all(c > 0 for c in r)), None)
    a = None
    starts = [None]
    if w is not None:
        phi0 = [min(Fraction(r[i], w[i]) for i in range(n) if w[i]) for r in rays]
        for c in (0.0, 0.25, 1.0, 4.0):
            starts.append([0.0 if i in basis else float(phi0[i]) - c for i in range(N)])
    wr = wallrows(rows, cones)
    for st in starts:
        a = solve(wr, N, basis, iters=int(__import__('os').environ.get('SWEEPS','20000')), start=st)
        if a is not None: break
    name = path.split('/')[-1].replace('.fan.txt', '')
    if a is None:
        print('%-16s no strictly concave support function found (search failed, not a disproof)' % name); return False
    D = 1 << 20
    aq = [Fraction(0) if i in basis else Fraction(round(a[i] * D), D) for i in range(N)]
    bad = 0; margin = None
    for row, sig, v in rows:
        s = sum(c * x for c, x in zip(row, aq))
        if s <= 0: bad += 1
        margin = s if margin is None else min(margin, s)
    ok = (bad == 0)
    print('%-16s %d rays, %d cones, %d strict inequalities: %s  (min margin %s)'
          % (name, N, len(cones), len(rows), 'ALL SATISFIED -> projective' if ok else '%d violated' % bad, margin))
    if ok:
        open(path.replace('.fan.txt', '.projectivity-float.txt'), 'w').write(
            'produced-by: scripts/projectivity.py (float relaxation, superseded)\n'
            'Strictly concave support function proving pi: T -> A^n is projective.\n'
            'phi(x) = min over maximal cones sigma of <m_sigma, x>, where m_sigma interpolates the\n'
            'heights below on the rays of sigma.  Strict concavity was verified exactly: for every\n'
            'maximal cone sigma and every ray v not in sigma, <m_sigma, v> - a_v > 0.\n\n'
            'rays    = %s\nheights = %s\n\n%d strict inequalities checked, minimum margin %s\n'
            % (rays, [str(x) for x in aq], len(rows), margin))
    return ok

paths = sorted(glob.glob(sys.argv[1] if len(sys.argv) > 1 else 'data/certificates/*.fan.txt'))
res = [run(p) for p in paths]
print('TOTAL: %d/%d fans proved projective' % (sum(res), len(res)))
