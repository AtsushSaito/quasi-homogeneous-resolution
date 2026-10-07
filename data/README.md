# Data

`certificates/` holds one certificate per sample for 11 samples (`E8_p2`, `E60_p2`, `BP222223_p7`, `curvemu3_p3`,
`dim3mixed_p3`, `dim4mixed_p3`, `dim5mu3_p3`, `dim6_p5`, `dim6mu2_p3`, `nwf2221_p2`, `surfmu3_p3`).
They are written by `src/certify.m2` (`M2 --script src/certify.m2 -- E8_p2`):

| file | content |
|---|---|
| `<name>.txt` | the checks (0) isolatedness, (1) the toric variety `T` is smooth, (2) `T -> A^n` is proper (exact combinatorial test), (3) isomorphism off the origin (all added rays are interior), (4) the strict transform is smooth in every chart, (5) the exceptional locus is a simple normal crossings divisor, (6) the number of unit-ideal identities, and a verdict |
| `<name>.fan.txt` | rays and maximal cones of `T` (input of `scripts/projectivity_exact.py`) |
| `<name>.cofactors.txt` | for each smoothness claim, generators `h_i` and cofactors `g_i` with `sum g_i h_i = 1` (re-expanded by `scripts/verify_cofactors.py`) |

A certificate records the checks run on one sample.  It uses the properness criterion for toric morphisms
(Cox-Little-Schenck, Thm 3.4.11) and no resolution theorem.  `verify_cofactors.py` checks that the identities hold; it does not
check that the `h_i` generate the ideal that the certificate claims they do (see its docstring).
