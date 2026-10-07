# Macaulay2 pitfalls met while writing this code

Environment: Macaulay2 1.26.06 (Homebrew), macOS, September 2026.  Translation of the Japanese working note
`notes-ja/m2-notes.md`; the symptoms were observed with this version and may differ in others.

| # | symptom | workaround used here |
|---|---|---|
| 1 | `InvariantRing`: `diagonalAction(W, {r}, R)` raises an error when the characteristic divides the order of a cyclic factor, i.e. exactly when `p | r` | a `mu_r` action is a `Z/r`-grading, so enumerate the invariant monomials of degree `<= r` and keep the minimal ones (`muInvariantMonomials` in `src/qh.m2`); generators have degree `<= r` by a pigeonhole argument on prefix sums |
| 2 | `singularLocus` on the presentation `S/I` of a quotient singularity (8 generators, 31 relations, codimension 6) did not return in 120 s | the computation involves about 20 million 6x6 minors.  Read the local type from the tangent weights (`qhPredict`) instead; use Groebner bases for the singular locus only up to codimension 3 |
| 3 | `res` is a protected symbol in 1.26 (an alias of `freeResolution`); `res = ...` fails | use another variable name (`result0`, ...) |
| 4 | `homogenize(f, t)` fails with "improper weight function" over `GF(q)`, `q = p^e`, `e >= 2` | homogenise by hand from `listForm` |
| 5 | `factor` returns constant factors as elements of the coefficient field (for instance `-1` in characteristic 3), and `degree` of such a factor is `{}`, so `first` fails | exclude with `ring q =!= Yr` |
| 6 | the standard output of `M2 --script` is block-buffered when piped to `head`; progress is not visible | redirect to a file and `tail` it; for long jobs append to a file with `openOutAppend`/`close` after each line |
| 7 | a Homebrew `M2` can fail to start asking for `libnauty-2.9.1.dylib` when only nauty 2.9.3 is installed | `brew reinstall macaulay2` |
| 8 | `(getSymbol "y")_j` as ring variables while a variable `y` exists: warning "clearing value of symbol y" | give chart variables a name that cannot clash, such as `yy` |
| 9 | counting the points of a 0-dimensional scheme orbit by orbit: adding `I + (y_j : j in tau)` reduces the scheme and loses multiplicity | take the length `N(tau)` of `saturate(I, prod_{j not in tau} y_j)` and use inclusion-exclusion `exact(tau) = N(tau) - sum_{tau' < tau} exact(tau')` |
| 10 | `hilbertFunction(a, R/I)` uses the grading of the ring; for a standard-graded ring it does not give weighted dimensions | rebuild the ring with `Degrees => w` and `sub` |
| 11 | the output of a computation is lost when a shell `timeout` sends SIGTERM, because it is buffered; `alarm` does not interrupt a running computation | one process per case, with a shell `timeout`; print and flush one line per finished case (`scripts/sweep_a2.sh`) |
| 12 | `toList(-1 : L)` does not raise an error, it returns `{}` | never use a sentinel such as `-1` as a repetition count |
| 13 | in a script, a continuation line that begins with `<<` after a complete expression starts a new statement; inside `for ... do` this silently leaves the loop body | wrap the body in parentheses |
| 14 | `toString s#"w"` parses as `(toString s)#"w"` | write `toString(s#"w")` |
