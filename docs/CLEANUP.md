# What was moved, removed, regenerated, and why

This file records the preparation of the repository for publication (2026-10-07), starting from a working copy of
the 80 files that had been selected from the private research repository.  Nothing was deleted without being
listed here; when in doubt a file was kept.

## Moved (content unchanged unless stated)

| from | to | reason |
|---|---|---|
| `qh.m2`, `StackyFan.m2`, `bergh_local.m2`, `corpus.m2`, `certify.m2` | `src/` | the research libraries had been mixed with scripts in the root; `load` paths adjusted; comments that used internal labels rewritten |
| `run_corpus.sh`, `run_one.m2`, `list_corpus.m2`, `random_search.m2` | `scripts/` | drivers, not libraries; paths adjusted |
| `tests/sweep_a2.m2`, `tests/sweep_one.m2` | `scripts/` | they are used by `scripts/sweep_a2.sh`, and are not tests |
| `experiments/certificates/` | `data/certificates/` | data, not experiments (regenerated, see below) |
| `experiments/LOG.md` | `docs/notes-ja/experiment-log.md` | a log in Japanese |
| `docs/statements.md`, `references.md`, `existence-audit.md`, `bergh-algorithm.md`, `evidence-2026-09-09.md`, `m2-notes.md` | `docs/notes-ja/` | working notes in Japanese; each got a banner line and a glossary (`notes-ja/README.md`); replaced for readers by the new English `MATH.md`, `REFERENCES.md`, `M2_NOTES.md` |
| `tests/regress.m2`, `smoke.m2`, `test_algorithmB.m2`, `certificate.m2`, `properness.m2` | `tests/m2/` | grouped with the new assertion-based tests; assertions added where the script only printed (`regress`, `test_algorithmB`, `smoke`, `certificate`) |

## Removed

| file | reason |
|---|---|
| `scripts/snapshot.sh` | a helper of the private workflow: it created dated `experiments/YYYY-MM-DD-<label>/` directories and appended a Japanese stub to `experiments/LOG.md`; both the directories and the log no longer exist in this layout.  Easily recreated if needed. |
| `experiments/` (empty directory) | emptied by the moves above |

## Regenerated

* `data/certificates/*.txt`: regenerated with the current `src/certify.m2` (all 11 `CERTIFIED`).  Eight of the files
  differ from the earlier ones in the verdict line only (the sentence "No resolution theorem was cited" now says that the properness
  criterion for toric morphisms of Cox-Little-Schenck is used); three (`BP222223_p7`, `dim6mu2_p3`, `surfmu3_p3`) were
  older, shorter certificates and now contain the full set of checks.  The `.fan.txt` and `.cofactors.txt` files of
  those three samples are new.  Result: 696 of 696 identities verified (`scripts/verify_cofactors.py`), 11 of 11
  fans projective (`scripts/projectivity_exact.py`); earlier documents quote 564 and 8 for the eight certificates
  that existed then.

## Changed in content

* `README.md` rewritten; `docs/MATH.md`, `docs/REFERENCES.md`, `docs/CATALOG.md`, `docs/M2_NOTES.md` added.
* Statements weakened or corrected during the review: see "Corrections made" below.
* `tests/` extended (catalog, edge cases, unit tests of `qh.m2`), see `tests/README.md`.
* `scripts/evidence_md.py`: Japanese labels translated.
* `.gitignore` extended.

## Corrections made

* The text of the certificate verdict and the header of `certify.m2` no longer say that no theorem is used; the toric
  properness criterion is used, and is named.
* `src/qh.m2` no longer prints "L2 guaranteed by Aroca-Gomez-Morales-Mourtada Thm 1.3": that theorem needs a
  subdivision compatible with the Groebner fan of the ideal, which the code does not check, and the code verifies
  every example directly.
* README: "`R` normal" replaced by "`R` an integral domain" (the hypothesis used in the argument; normality is not
  needed).  The attribution of "step 1" to Wlodarczyk's Theorem 4.2.2 / Example 4.4.3 was made precise: that theorem is
  about the cobordant blow-up under an "almost homogeneous" hypothesis, and the example is about Brieskorn-type equations.
* The claim that Bergh's construction leaves the smooth locus untouched is not in Theorem 1.2 as stated; it is
  now marked as unverified (MATH.md, step 5).
* `tests/m2/smoke.m2` expected the chain `{3,2}` for `basicToricStackyFan(5,{1,2})`; the function presents the inverse
  type, so the correct chain is `{2,3}` (this was already known in the research notes).
* MATH.md notes that all 361 (A4) samples of the recorded corpus are Newton non-degenerate, so the corpus does not
  test the degenerate case.

## Known leftovers

* The package prints the warning "insufficient citation data: howpublished" at installation.
* `docs/notes-ja/` refers to files that are not in this repository (`tests/stratum_constancy.m2`, older evidence logs); these were one-off exploratory scripts and drafts, deliberately left out.
* `examples/toric_quotients.m2` takes about two minutes.
* The raw outputs of the corpus run (`results/<name>.txt`, 440 files) and of the random search were not kept; the
  summary table was.
