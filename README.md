# qh-resolution

Macaulay2 code, and a catalog of checked examples, for resolving isolated singularities of weighted-homogeneous
(quasi-homogeneous) type in **positive characteristic** by one weighted blow-up followed by Bergh's destackification
of the resulting tame quotient stack.

* `package/ToricDestackification.m2`: a Macaulay2 package for toric **stacky fans** and Bergh's destackification
  algorithm (Algorithms A and B of Bergh, Compositio 153 (2017)).  An implementation of a known algorithm, not a new one.
* `src/`: research code that builds, for a given equation and weights, the explicit toric resolution of the weighted
  blow-up and compares it with the prediction coming from the stabiliser strata.
* [`docs/CATALOG.md`](docs/CATALOG.md): **440 singularities** (rational double points in characteristics 2, 3, 5, 7,
  Brieskorn-Pham and Arnold surfaces, simple elliptic ones, and hypersurfaces up to dimension 6), each with the input
  needed to reproduce it, the expected result, and a statement of how well that result is supported.
* `tests/`: assertion-based tests, driven by the same catalog tables.  `sh tests/run_ci.sh` takes about 5 minutes.

**Status.**  Version 0.1, written in September-October 2026, not peer reviewed.  **Nothing here is a new theorem**:
the statement behind the code (statement M below) is, in substance, known; see [docs/MATH.md](docs/MATH.md) for what is
cited, what I derived myself, and what is not claimed.  The code was written with the help of an AI assistant
(see [Provenance](#provenance-use-of-ai)).

## The mathematics in four lines

Let `k` be a field of characteristic `p >= 0`, `R` a finitely generated N-graded integral `k`-algebra with `R_0 = k`,
`X = Spec R`, `v` its vertex.  Example: `R = k[x,y,z]/(z^2 + x^3 + y^5)` with weights `x:10, y:6, z:15` (degree 30).

> **M.**  If `X \ {v}` is smooth over `k`, there is a proper birational morphism `X~ -> X` from a smooth algebraic
> space (one weighted blow-up of the vertex, giving a smooth tame stack `[((X\{v}) x A^1)/G_m]` with stabilisers `mu_r`,
> then Bergh's destackification), whatever `p` is, even when `p` divides a weight, the degree, or a stabiliser order `r`.
> (That `X~ -> X` is moreover an isomorphism over `X \ {v}` is expected; see docs/MATH.md, step 5.)

Terms: a *stacky fan* is a fan with a positive integer *label* on each ray (the combinatorial datum of a toric stack);
*Algorithms A and B* are the two algorithms of Bergh's section 4 that make a stacky fan smooth by star subdivisions and
root constructions; *step A2* is the step of Algorithm A that picks the centre, and it leaves four choices open
("readings") that the code exposes as switches; a *stratum* is a locus of `Proj R` with a given non-trivial stabiliser
`mu_r`.  More in the glossary of docs/MATH.md, section 6.

For surfaces the stack's coarse space has cyclic quotient singularities `1/r(1,q)`, and Bergh's algorithm gives back the
Hirzebruch-Jung chains; the resulting graph (for `z^2 + x^3 + y^5` in characteristic 2: the `E_8` diagram, 8 curves of
self-intersection `-2`) is computed and compared with the classical value.

Sources: Bergh, *Functorial destackification of tame stacks with abelian stabilisers*, Compositio Math. 153 (2017),
Theorem 1.2 and Corollary 1.3; for the weighted (cobordant) blow-up Wlodarczyk, arXiv:2203.03090 (v4), Theorem 4.2.2,
which says that under an "almost homogeneous singularity" hypothesis the cobordant blow-up is regular (the stack of step 1
below plays that role here), and Example 4.4.3 for Brieskorn-type equations.  How each citation was checked: [docs/REFERENCES.md](docs/REFERENCES.md).

## Requirements

Macaulay2 (all results were produced with 1.26.06; no other version was tried) and Python 3 (standard library only, for
the checkers).  Nothing else is needed.

## Quick start

```
# from the repository root
M2 --script examples/e8_char2.m2        # E_8 in characteristic 2, weights (10,6,15): p divides two weights and the degree
M2 --script examples/negative.m2        # samples where the isolatedness hypothesis fails are detected and skipped
sh tests/run_ci.sh                      # the fast test set, about 5 minutes
```

The package, from the repository root:

```
path = prepend("./package/", path);
needsPackage "ToricDestackification"
F = stackyFan({{0,1},{5,-2}}, {1,1}, {{0,1}});   -- the cone of the singularity 1/5(1,2); rays, labels, maximal cones
coneMultiplicity(F, {0,1})                       -- 5
destackify F;                                    -- Bergh's Algorithm B, in place
isSmoothStackyFan F                              -- true
contractMinusOneCurves resolutionChain F         -- {3,2}, the Hirzebruch-Jung chain of 5/2
```

`installPackage("ToricDestackification")` after the `path` line installs the package with its documentation.

## Repository layout

```
package/    ToricDestackification.m2   the package (documentation and TEST blocks inside)
src/        qh.m2          checks of statement M on concrete examples (prediction, explicit toric resolution, comparison)
            StackyFan.m2   the same algorithm as the package, with switches for the four choices Bergh's step A2 leaves open;
                           cannot be loaded together with the package (tests/package_equivalence.sh compares them on 44 cases)
            bergh_local.m2 route 2: Bergh's algorithm on the local models of the strata
            corpus.m2      the sample library (440 samples)   certify.m2   writes a certificate for one sample
examples/   short scripts, run one at a time
tests/      run_ci.sh, run_all.sh, catalog/ (tables + runners), m2/ (assertion-based unit and regression tests); see tests/README.md
scripts/    run_corpus.sh and friends (re-run the whole corpus), Python checkers for the certificates, A2 sweep
data/       certificates/ (11 certificates), the format is described in data/README.md
results/    summary.tsv: one row per sample of the recorded corpus run (440 rows)
docs/       MATH.md, REFERENCES.md, CATALOG.md (generated), M2_NOTES.md, CLEANUP.md, notes-ja/ (working notes in Japanese, unedited,
            with internal labels and some outdated counts; read MATH.md first)
```

Why two copies of the algorithm?  `src/StackyFan.m2` is the research version used to experiment with the open choices of
step A2; `package/` is the version meant for reuse, with input validation and documentation.  The test
`tests/package_equivalence.sh` runs both on 44 cones and compares the outputs.

## What is verified, and how

| claim | support |
|---|---|
| 361 samples satisfy the hypothesis (characteristics 2, 3, 5, 7; dimensions 2 to 6) and get the verdict CONFIRM: the explicit toric resolution has smooth strict transform in every chart, the toric map is proper and an isomorphism off the origin.  For the 302 surfaces among them, the resolution graph also agrees with the prediction from the stabiliser strata; **for the 59 samples of dimension 3 and higher only the first three checks were made, no prediction is compared**.  79 samples where the hypothesis fails are skipped (SKIP); no sample disagrees | `results/summary.tsv` (recorded run); `SUMMARY=results/rerun.tsv scripts/run_corpus.sh` recomputes it in about 25 minutes; 66 CONFIRM and 8 SKIP rows are re-run by the fast tests |
| for 11 of these a certificate with independent checks (exact properness test, 696 unit-ideal identities re-expanded in Python, exact rational test that the toric variety is projective) | `data/certificates/`, `scripts/verify_cofactors.py`, `scripts/projectivity_exact.py` |
| Bergh's algorithm gives the Hirzebruch-Jung chain, computed independently, for all cyclic quotients `1/r(1,q)`, `r <= 16` (79 cases; the fast tests cover `r <= 12`), and smooth outputs with exactly unimodular cones for rank-3 and rank-4 test cones | `tests/catalog/` |
| the package and the research code agree on 44 cones (both are my implementation of the same reading of Bergh, so this is a refactoring check, not an independent confirmation) | `tests/package_equivalence.sh` |

The word "confirmed" is used in the catalog only for the evidence classes L, X and V described there; a value that is
only the output of the implementation is marked O.  For the rows of classes X and O the expected values of the fast tests are
copied from the recorded run of the same code: they are regression tests, not independent checks.

## What is not verified

* Statement M in general: it relies on the cited theorems and on four short steps that are my own derivations
  ([docs/MATH.md](docs/MATH.md), steps 1-4).  In particular I have not verified that the blow-up centres of Bergh's
  construction stay inside the stacky locus, so "isomorphism over `X \ {v}`" is checked in the examples only.
* The route through an explicit toric resolution is expected to work for Newton non-degenerate equations over perfect
  fields (Aroca-Gomez-Morales-Mourtada, Theorem 1.3, whose hypothesis on the subdivision I do not check); in the code
  every example is verified chart by chart instead.
* Minimality, `G_m`-equivariance and projectivity of the resolution in general.
* The version with "regular" instead of "smooth over `k`" (non-perfect fields).
* Termination in practice of Algorithm B for high multiplicities: step A2 of Bergh's algorithm does not fix an order,
  and for the rank-3 cone `(1,2,5)` only some of the 16 readings finish in reasonable time (see the catalog).
* Prior implementations: I looked in the Macaulay2, Sage, polymake and OSCAR documentation and did not find an
  implementation of Bergh's destackification.  That is a search of limited scope, not a claim that none exists.

## Provenance (use of AI)

This repository was developed with Claude (Anthropic's AI assistant), which drafted much of the Macaulay2 and Python
code, the documentation and the tests, and read the cited papers.  I chose the question, decided what to claim and
what not to claim, ran the computations and decided how they should be checked.  The citations were re-compared with
the arXiv texts by the assistant (2026-10-07); I have **not** myself re-read the original text of Satriano, Cor. 1.8
or Bergh, Thm A.1(e), and the final read-through of the mathematical documents by a human specialist is still to be done.
Corrections are welcome.

## Background

This started as a personal project (September 2026) after a master's degree in which I had worked on resolution of
quasi-homogeneous singularities in positive characteristic without finishing the resolution.  It is not part of any thesis.

## License and author

MIT, see [LICENSE](LICENSE).  Author: Atsushi Saito.
