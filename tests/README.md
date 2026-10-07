# Tests

Everything runs with Macaulay2 (1.26.06) and Python 3 from the repository root.  Every check is an `assert` (or a
comparison that makes the runner exit with a non-zero status); a script that merely prints is not counted as a test.

| command | content | time |
|---|---|---|
| `sh tests/run_ci.sh` | the fast set below | about 5 minutes |
| `sh tests/run_all.sh` | the fast set plus all catalog rows, cyclic quotients up to `r = 16`, and all examples | about 40 minutes |

## What the fast set runs

| step | file | what it checks |
|---|---|---|
| catalog consistency | `catalog/check_catalog.py` | tables vs. the recorded corpus run (440 rows, 361 CONFIRM, 79 SKIP, no MISMATCH), Hirzebruch-Jung table recomputed in Python, the 11 certificates re-verified by `scripts/verify_cofactors.py` and `scripts/projectivity_exact.py` |
| package check | `package_check.sh` | `installPackage` (builds the documentation, runs every documentation example), `check` (the TEST blocks inside the package) |
| package edge cases | `m2/test_package_edges.m2` | about 1250 checks: Hirzebruch-Jung round trip for `r <= 40`, validation errors of every constructor, degenerate inputs (dependent rays, empty cones, labels only, smooth fan, rank 1), idempotence, `MaxIterations`, independence from the random seed, unimodularity of outputs |
| catalog: cyclic quotients | `catalog/run_cyclic.m2` | Bergh's algorithm vs. the Hirzebruch-Jung expansion of `r/q`, `r <= 12` (45 cases) |
| catalog: simplicial cones | `catalog/run_fans.m2` | rank 2, 3, 4 cones: multiplicity, number of rays and cones of the output, exact unimodularity, rays inside the original cone |
| catalog: A2 readings | `catalog/run_switches.m2` | the 16 readings of Bergh's step A2 all give correct results on surfaces `r <= 6` and on the rank-3 cone of multiplicity 3 |
| catalog: hypersurfaces | `catalog/run_hypersurfaces.m2` | 74 representative samples: Jacobian test of the isolatedness hypothesis, then verdict, stabiliser orders, resolution graph, genus |
| research code | `m2/test_qh_units.m2`, `m2/regress.m2`, `m2/test_algorithmB.m2`, `m2/smoke.m2`, `m2/certificate.m2`, `m2/properness.m2` | building blocks of `src/qh.m2` (invariants of `mu_r`, initial forms of the Newton polyhedron, exact properness test, error handling), one full certificate in dimension 4 |
| equivalence | `package_equivalence.sh` | the package and `src/StackyFan.m2` give identical output on 44 cones |

## The catalog

`catalog/*.tsv` are the tables behind [../docs/CATALOG.md](../docs/CATALOG.md); the runners read them, so adding a
row adds a test.

| table | rows | written by |
|---|---|---|
| `hypersurfaces.tsv` | 440 (74 `ci`) | `gen_hypersurfaces.py` from `results/summary.tsv` and `scripts/dump_corpus.m2` |
| `cyclic.tsv` | 79 (45 `ci`) | `gen_cyclic.py` (exact integers, independent of the Macaulay2 code) |
| `fans.tsv` | 10 | by hand; values taken from a run, class O unless noted |
| `switches.tsv` | see CATALOG.md | by hand, from `run_switches.m2` and `scripts/sweep_a2.sh` |

After changing a table: `python3 tests/catalog/make_catalog_md.py` regenerates `docs/CATALOG.md`.
Single rows: `ONLY=E8_p2,D4_p3 M2 --script tests/catalog/run_hypersurfaces.m2`.

Not in the fast set: the full re-run of the corpus (`scripts/run_corpus.sh`, about 25 minutes), the sweep over the 16
readings on the rank-3 cone `(1,2,5)` (`CASES=rank3 sh scripts/sweep_a2.sh`, up to an hour), and `examples/toric_quotients.m2`
(about 2 minutes) which is run by `run_all.sh`.
