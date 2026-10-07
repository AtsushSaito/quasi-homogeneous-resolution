# Working notes (Japanese, unedited)

The files in this directory are the working notes written while the project was being carried out, in Japanese,
kept as they were.  They are **not** the documentation of the repository; read [../MATH.md](../MATH.md),
[../REFERENCES.md](../REFERENCES.md) and [../CATALOG.md](../CATALOG.md) first.  Where a note and those pages
differ, the pages in `docs/` are the later and corrected version (the references were re-compared with the arXiv
texts on 2026-10-07, see REFERENCES.md; some theorem attributions in the notes are stated more strongly than they
are there).

| file | content |
|---|---|
| `statements.md` | the statement M, lemmas L1-L8 (stabilisers, tangent weights, resolution graph of surfaces, spreading out, ...) with the status of each |
| `references.md` | the annotated bibliography as it was before the re-check |
| `existence-audit.md` | a step-by-step audit of the existence argument; the "joints" `SEAM-1` ... `SEAM-6` are its six weak points |
| `bergh-algorithm.md` | a reading of Bergh's algorithm; `OI-1` is the open question about the order in step A2 |
| `evidence-2026-09-09.md` | a log of the code review of 2026-09-09 and the corpus re-run (416 -> 440 samples) |
| `experiment-log.md` | the experiment log (counts in it are those of the time) |
| `m2-notes.md` | Macaulay2 pitfalls; English version: [../M2_NOTES.md](../M2_NOTES.md) |

## Glossary of the internal labels

| label | meaning |
|---|---|
| M, "proposition M" | Statement M of [../MATH.md](../MATH.md) |
| A4 | hypothesis: `X minus {vertex}` is smooth over `k` |
| P1, P2; L2 | route 1 (explicit toric resolution, `src/qh.m2`; called L2 in code comments) and route 2 (stacky, Bergh's algorithm) |
| SEAM-1 ... SEAM-6 | six places in the existence argument where one result is passed to the next: 1 properness of the weighted blow-up; 2 isomorphism over the smooth locus; 3 tangent weights give the local model (Satriano Cor 1.8); 4 compatibility of local constructions when gluing; 5 diagonalisability of the group in Bergh's Thm A.1(e); 6 the cases of dimension <= 3 are known |
| OI-1 | open item 1: Bergh's step A2 leaves four choices open |
| E1, E2 | existence of a resolution for an individual example (by construction) vs. for all cases (by the cited theorems) |
| S1-S6 | steps of the proof in `existence-audit.md` |
| C1-C10 | families of the sample library `src/corpus.m2` (C1 rational double points, C2 Brieskorn-Pham surfaces, C3 Arnold, C4 simple elliptic, C5/C6 threefolds/fourfolds, C10 dimensions 5-6; C7-C9: smaller special series not in the catalog) |
| `[F-AI]`, `[F?]`, `[D]`, `[C]`, `[Q]` | status labels: read by the AI assistant in the source / not checked or second-hand / derived in this project / confirmed by computation / open |
| "the review document" | an earlier text with the first formulation of M (not part of this repository) |

References inside these notes to files that are not in this repository (for example `tests/stratum_constancy.m2`
and older evidence logs) point to earlier working files that were deliberately left out; see
[../CLEANUP.md](../CLEANUP.md).
