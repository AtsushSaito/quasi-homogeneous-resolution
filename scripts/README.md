# Scripts

| script | purpose |
|---|---|
| `run_corpus.sh [C1 C4 ...]` | run `qhVerify` on every sample of `src/corpus.m2`, or on the given families; results are appended to `$SUMMARY` (see below) |
| `run_one.m2`, `list_corpus.m2` | helpers of `run_corpus.sh` |
| `dump_corpus.m2` | print the sample library as TSV (input of `tests/catalog/gen_hypersurfaces.py`) |
| `random_search.m2` | random search of weighted-homogeneous `f` in three variables with the isolatedness hypothesis but not convenient or Newton-degenerate (`-- p=2 seed=1 samples=8 wmax=5 dmax=15`) |
| `verify_cofactors.py` | independent check (Python, exact arithmetic) that the unit-ideal identities of the certificates are identities |
| `projectivity_exact.py`, `projectivity.py` | decide by exact rational linear programming (resp. floating point) whether the toric variety of a certificate fan is projective |
| `summarize.py`, `evidence_md.py` | summaries of `results/summary.tsv` |
| `sweep_a2.sh`, `sweep_one.m2`, `sweep_a2.m2` | one process per reading of Bergh's step A2 (16 readings), with a shell time limit; `CASES=surfaces|rank3|all LIMIT=200 OUT=dir sh scripts/sweep_a2.sh` |

`run_corpus.sh` appends to `$SUMMARY` (default `results/summary.tsv`, the recorded run).  Samples already present are
skipped, so to recompute use `SUMMARY=results/rerun.tsv`.  It fails if a sample produced no row.  About 25 minutes for
all 440.  Per-sample outputs go to `results/<name>.txt` (git-ignored).

Run everything from the repository root; the scripts change to it themselves where needed.
