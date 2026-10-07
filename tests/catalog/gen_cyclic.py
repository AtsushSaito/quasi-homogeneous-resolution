#!/usr/bin/env python3
"""Write tests/catalog/cyclic.tsv: the Hirzebruch-Jung continued fraction of r/q for all coprime
1 <= q < r <= RMAX, computed with exact integer arithmetic in Python.

This is deliberately an implementation independent of the Macaulay2 code that is being tested:
the table is the expected value, the M2 runner (run_cyclic.m2) compares Bergh's algorithm against it.

usage: python3 tests/catalog/gen_cyclic.py [RMAX]    (default 16)
"""
import sys
from math import gcd

def hj(r, q):
    """r/q = b1 - 1/(b2 - 1/(...)),  b_i >= 2."""
    out = []
    while q:
        b = -(-r // q)            # ceiling(r/q)
        out.append(b)
        r, q = q, b * q - r
    return out

def hj_value(bs):
    """Evaluate [b1,...,bk] back to r/q as a Fraction (round-trip check)."""
    from fractions import Fraction
    x = Fraction(bs[-1])
    for b in reversed(bs[:-1]):
        x = b - 1 / x
    return x

rmax = int(sys.argv[1]) if len(sys.argv) > 1 else 16
rows = []
for r in range(2, rmax + 1):
    for q in range(1, r):
        if gcd(r, q) != 1:
            continue
        bs = hj(r, q)
        from fractions import Fraction
        assert hj_value(bs) == Fraction(r, q)
        note = ""
        if q == 1: note = "1/r(1,1): one curve of self-intersection -r"
        elif q == r - 1: note = "A_{r-1}: chain of r-1 curves of self-intersection -2"
        tier = "ci" if r <= 12 else "heavy"
        rows.append((f"cyc_{r}_{q}", r, q, "{" + ", ".join(map(str, bs)) + "}", len(bs), tier, note))
with open(__file__.rsplit("/", 1)[0] + "/cyclic.tsv", "w") as f:
    f.write("id\tr\tq\texpected_hj\texpected_curves\ttier\tnote\n")
    for row in rows:
        f.write("\t".join(map(str, row)) + "\n")
print(len(rows), "rows")
