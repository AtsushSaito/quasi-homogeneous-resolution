#!/usr/bin/env python3
"""Decide projectivity exactly, with no floating point anywhere.

A toric morphism from a simplicial refinement of the orthant is projective exactly when there
are heights a_v on the rays whose interpolating piecewise linear function is strictly concave:
<m_sigma, v> - a_v > 0 for every maximal cone sigma and every ray v not in sigma.  It is enough
to impose this across walls; the rest then follows, and we verify all of them anyway at the end.

That is a linear feasibility problem.  Writing a_i = p_i - m_i with p, m >= 0 and maximising t
subject to (row . a) - t >= 0 and t <= 1 puts it in the form

    maximise t   subject to   A x <= b,  x >= 0,   with b >= 0,

so the origin is already a basic feasible solution and no phase one is needed.  The simplex is
run in exact rational arithmetic with Bland's rule, which cannot cycle.  If the optimum is
positive the fan is projective and we print a certificate; if it is zero, no strictly concave
support function exists, and the fan is genuinely NOT projective.  Either way the answer is a
proof, not a search that gave up.
"""
import sys, glob, ast
from fractions import Fraction as Q

def inv_unimodular(M):
    n = len(M)
    A = [[Q(M[i][j]) for j in range(n)] + [Q(int(i == j)) for j in range(n)] for i in range(n)]
    for c in range(n):
        piv = next(r for r in range(c, n) if A[r][c] != 0)
        A[c], A[piv] = A[piv], A[c]
        pv = A[c][c]; A[c] = [x / pv for x in A[c]]
        for r in range(n):
            if r != c and A[r][c] != 0:
                f = A[r][c]; A[r] = [x - f * y for x, y in zip(A[r], A[c])]
    return [row[n:] for row in A]

def build(rays, cones):
    n = len(rays[0]); N = len(rays); rows = []
    for sig in cones:
        Vi = inv_unimodular([rays[i] for i in sig])
        for v_idx in range(N):
            if v_idx in sig: continue
            v = rays[v_idx]
            coef = [sum(Q(v[k]) * Vi[k][j] for k in range(n)) for j in range(n)]
            row = [Q(0)] * N
            for j, i in enumerate(sig): row[i] += coef[j]
            row[v_idx] -= 1
            rows.append((row, sig, v_idx))
    return rows

def wallrows(rows, cones):
    cset = {tuple(sorted(c)) for c in cones}; out = []
    for row, sig, v in rows:
        for k in range(len(sig)):
            if tuple(sorted(list(sig[:k]) + list(sig[k+1:]) + [v])) in cset:
                out.append((row, sig, v)); break
    return out

def simplex(A, b, c):
    """maximise c.x s.t. Ax <= b, x >= 0, assuming b >= 0.  Bland's rule, exact.  Returns x."""
    m = len(A); n = len(c)
    T = [list(A[i]) + [Q(1) if j == i else Q(0) for j in range(m)] + [b[i]] for i in range(m)]
    obj = [-x for x in c] + [Q(0)] * m + [Q(0)]
    basis = list(range(n, n + m))
    while True:
        piv_c = next((j for j in range(n + m) if obj[j] < 0), None)   # Bland: lowest index
        if piv_c is None: break
        piv_r, best = None, None
        for i in range(m):
            if T[i][piv_c] > 0:
                r = T[i][-1] / T[i][piv_c]
                if best is None or r < best or (r == best and basis[i] < basis[piv_r]):
                    best, piv_r = r, i
        if piv_r is None: raise RuntimeError("unbounded")
        pv = T[piv_r][piv_c]
        T[piv_r] = [x / pv for x in T[piv_r]]
        for i in range(m):
            if i != piv_r and T[i][piv_c] != 0:
                f = T[i][piv_c]; T[i] = [x - f * y for x, y in zip(T[i], T[piv_r])]
        if obj[piv_c] != 0:
            f = obj[piv_c]; obj = [x - f * y for x, y in zip(obj, T[piv_r])]
        basis[piv_r] = piv_c
    x = [Q(0)] * (n + m)
    for i, bi in enumerate(basis): x[bi] = T[i][-1]
    return x[:n]

SUFFIX = '.fan.txt'

def run(path):
    # The certificate path is derived by replacing the suffix.  If the input does not carry it the
    # replace is a no-op and we would open the input file for writing and destroy it, so refuse.
    if not path.endswith(SUFFIX):
        print('%-16s skipped: not a *%s file' % (path.split('/')[-1], SUFFIX))
        return 'skip'
    txt = open(path).read().strip().splitlines()
    if len(txt) < 2:
        print('%-16s skipped: expected a rays line and a cones line' % path.split('/')[-1])
        return 'skip'
    rays = ast.literal_eval(txt[0].replace('{', '[').replace('}', ']'))
    cones = ast.literal_eval(txt[1].replace('{', '[').replace('}', ']'))
    N = len(rays)
    basis = {i for i, r in enumerate(rays) if sum(r) == 1 and max(r) == 1}
    free = [i for i in range(N) if i not in basis]          # heights fixed to 0 on the standard basis
    rows = build(rays, cones); wr = wallrows(rows, cones)
    # variables: p_j, m_j for j in free, then t.  Constraint  -(row . a) + t <= 0.
    nv = 2 * len(free) + 1
    A, b = [], []
    for row, _, _ in wr:
        con = [Q(0)] * nv
        for j, i in enumerate(free):
            con[j] = -row[i]; con[len(free) + j] = row[i]
        con[nv - 1] = Q(1)
        A.append(con); b.append(Q(0))
    con = [Q(0)] * nv; con[nv - 1] = Q(1); A.append(con); b.append(Q(1))   # t <= 1
    c = [Q(0)] * nv; c[nv - 1] = Q(1)
    x = simplex(A, b, c)
    t = x[nv - 1]
    name = path.split('/')[-1][:-len(SUFFIX)]
    if t == 0:
        print('%-16s %2d rays %2d cones : NOT PROJECTIVE (exact LP optimum is 0)' % (name, N, len(cones)))
        return 'no'
    a = [Q(0)] * N
    for j, i in enumerate(free): a[i] = (x[j] - x[len(free) + j]) / t
    bad = 0; margin = None
    for row, sig, v in rows:                                # verify ALL of them, not just walls
        s = sum(cc * y for cc, y in zip(row, a))
        if s <= 0: bad += 1
        margin = s if margin is None else min(margin, s)
    if bad:
        print('%-16s INTERNAL ERROR: %d of %d inequalities violated' % (name, bad, len(rows)))
        return 'err'
    print('%-16s %2d rays %2d cones : PROJECTIVE, %d strict inequalities, min margin %s'
          % (name, N, len(cones), len(rows), margin))
    open(path[:-len(SUFFIX)] + '.projectivity.txt', 'w').write(
        'produced-by: scripts/projectivity_exact.py (exact rational simplex)\n'
        'Strictly concave support function proving that pi is projective.\n'
        'phi(x) = min over maximal cones sigma of <m_sigma, x>, where m_sigma interpolates the\n'
        'heights below on the rays of sigma.  Found by an exact rational simplex (Bland\'s rule,\n'
        'no floating point) and verified exactly: for every maximal cone sigma and every ray v\n'
        'not in sigma, <m_sigma, v> - a_v > 0.\n\n'
        'rays    = %s\nheights = %s\n\n%d strict inequalities checked, minimum margin %s\n'
        % (rays, [str(y) for y in a], len(rows), margin))
    return 'yes'

paths = sorted(glob.glob(sys.argv[1] if len(sys.argv) > 1 else 'data/certificates/*' + SUFFIX))
res = [run(p) for p in paths]
print('TOTAL: %d projective, %d not projective, %d errors, %d skipped, out of %d'
      % (res.count('yes'), res.count('no'), res.count('err'), res.count('skip'), len(res)))
# Exit nonzero on anything a caller would want to gate on, so a driver can rely on the status.
sys.exit(1 if (res.count('no') or res.count('err') or not res.count('yes')) else 0)
