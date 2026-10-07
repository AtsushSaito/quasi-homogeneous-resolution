# Mathematical background

This page states precisely what the code is about, where the underlying result comes from, which steps I
checked and which I did not.  **Nothing here is a new theorem.**  Citations are listed with their checking
status in [REFERENCES.md](REFERENCES.md).

## 1. Setting

* `k` a field, `R` a finitely generated N-graded k-algebra that is an integral domain, `R_0 = k`;
  `X = Spec R`, and `v` the vertex (the point defined by the irrelevant ideal `R_+`).
* The multiplicative group `G_m` acts on `X` through the grading; `Y = Proj R` is the quotient of `X \ {v}`.
* In the catalog and the code, `R = k[x_1, ..., x_n]/(f)` with `f` quasi-homogeneous for positive integer
  weights `w = (w_1, ..., w_n)`, `gcd(w) = 1` and weighted degree `d`.
* **(A4)** (the name used in the code and the tables): `X \ {v}` is smooth over `k`.  For a hypersurface this is
  the Jacobian condition `dim k[x]/(f, df) = 0`.

## 2. The statement (called "M" in code comments)

> **Statement M.**  Under the setting above and (A4) there are a smooth algebraic space `X~` over `k` and a proper
> birational morphism `pi: X~ -> X`.  There is no restriction on `dim X`, on the characteristic `p`, on whether
> `p` divides a weight `w_i`, or on whether `p` divides `d`.  (Moreover `pi` is expected to be an isomorphism
> over `X \ {v}`; see the remark after step 5.)

In characteristic 0 this is classical.  The point of the project is positive characteristic, where
`p | w_i` or `p | d` makes the stabilisers of the `G_m`-action on the weighted blow-up non-reduced (`mu_r` with
`p | r`), so that the blow-up is no longer a Deligne-Mumford stack.

**M is known, in substance.**  It is a direct application of Bergh's destackification theorem to the stacky
weighted blow-up of the vertex.  Bergh's Corollary 1.3 and Wlodarczyk's treatment of weighted ("cobordant")
blow-ups are the closest statements I found; I did not find M written in exactly this form.  The repository
contributes running code, a catalog of checked examples, and a record of what was and was not verified.

## 3. Proof outline and status of each step

Labels: **cited** = a statement of a published source, whose text I compared with the arXiv version
(see REFERENCES.md); **derived** = my own short argument, not reviewed by anyone else; **checked** = verified by
computation in the examples of this repository.

1. **The stacky weighted blow-up is smooth.**  `Y := [((X \ {v}) x A^1) / G_m]` with
   `t . (u, s) = (t.u, t^{-1} s)` is a quotient of a smooth scheme (by (A4)) by the smooth group `G_m`, hence a
   smooth algebraic stack over `k`.  *derived (elementary).*
2. **Stabilisers.**  At a point with `s != 0` the stabiliser is trivial.  At `s = 0` it is the stabiliser in `G_m`
   of `u in X \ {v}`, a closed subgroup scheme of `G_m` which is not all of `G_m` (the weights are positive), hence
   `mu_r` with `r = gcd{ w_i : u_i != 0 }` (for hypersurfaces).  Closed subgroup schemes of `G_m` are `G_m` and the
   `mu_r`, over any field.  The inertia is finite.  *derived;* the group-theoretic fact is standard.
   If `p | r` the group scheme `mu_r` is not etale.  The group `alpha_p` never occurs.
3. **Tameness.**  `mu_r` is diagonalisable, hence linearly reductive in every characteristic; a stack with finite
   inertia is tame (in the sense of Abramovich-Olsson-Vistoli) iff its stabilisers are linearly reductive
   (Bergh, Thm A.1 (a) <=> (b), which restates AOV Thm 3.2).  So `Y` is tame with diagonalisable stabilisers,
   and not Deligne-Mumford when `p | r`.  *cited (AOV Prop 2.10, 2.13; Bergh Thm A.1).*
4. **Properness.**  `(u, s) |-> s.u` descends to `rho: Y -> X`, an isomorphism over `X \ {v}` (the slice
   `s = 1`).  `Y` is a closed substack of `[((A^n \ 0) x A^1)/G_m]`, the stacky weighted blow-up of the origin of
   `A^n`, whose coarse space is the toric variety of a subdivision of the orthant supported on the whole orthant;
   such a toric morphism is proper (Cox-Little-Schenck, Thm 3.4.11, the criterion `phi^{-1}(|Sigma'|) = |Sigma|`),
   and the coarse map of a stack with finite inertia is proper (Keel-Mori).  *derived from cited facts (the tameness of the ambient stack follows from step 3; the toric criterion is quoted from Cox-Little-Schenck and was not re-checked in this session).  This is the
   thinnest step of the general argument.  In every example of the catalog properness of the toric map is checked
   directly by an exact combinatorial test (`refinesOrthantExact`).*
5. **Destackification.**  Bergh's Theorem 1.2 applies to the standard pair `(Y, empty divisor)`: there is a sequence
   of smooth stacky blow-ups `Y_m -> ... -> Y_0 = Y` whose last stack has smooth coarse space.  Then
   `Y_m^cs -> Y^cs -> X` is proper and birational, and `Y_m^cs` is a smooth algebraic space.  *cited (Thm 1.2,
   Def 2.1, 2.3).*  The same conclusion can be reached through Bergh's Corollary 1.3 applied to `Y^cs`, which has
   simplicial toric singularities (the etale-local structure `[U/mu_r]` is Bergh Thm A.1 (e); the linearisation of a
   `mu_r`-action at a fixed point is the first paragraph of the *proof* of Satriano, Cor 1.8).

   *Birationality.*  Each smooth blow-up and each root stack is an isomorphism away from its centre, which is a proper
   closed substack of positive codimension (this is how I read Bergh's Definition 2.2; I did not check the point in detail),
   so `Y_m^cs -> Y^cs` is birational; `Y^cs -> X` is birational by step 4.

   *Remark (isomorphism over `X \ {v}`).*  The open immersion `X \ {v} -> Y` (the slice `s = 1`) is smooth and
   stabiliser preserving, and Theorem 1.2 says the construction is functorial for such maps; the empty-divisor pair
   `(X \ {v}, empty)` is a smooth scheme, which is already a destackification, so one expects the sequence over it to be
   empty and `pi` to be an isomorphism over `X \ {v}`.  That the algorithm indeed does nothing on an algebraic space
   (trivial stabilisers everywhere) is **not stated in Theorem 1.2** and I have not verified it against the algorithms,
   so I do not claim it as proved; it is checked directly in every catalog example whose resolution is computed by
   the toric route.  Statement M above is therefore claimed only as "proper birational".

6. **Local structure** (used only for predictions): at a point of a stratum with stabiliser `mu_r` the coarse space of
   `Y` is, etale locally, `A^{n-1}/mu_r` with weights read off the tangent space (a multiset `{w_j mod r}` minus the
   direction of `df` and minus one orbit direction, plus `-1` for `s`).  For a surface this is a cyclic quotient
   singularity `1/r(1,q)`, resolved by the Hirzebruch-Jung chain.  *derived (the "tangent weights" lemma in the Japanese
   working notes, `notes-ja/statements.md`, there labelled L2; unrelated to the code label L2 = route 1), checked
   by agreement with the explicit toric resolution on the 302 surfaces of the catalog with verdict CONFIRM; for
   dimension >= 3 the code compares no prediction.*

## 4. The two computational routes

* **Route 1: explicit toric resolution** (`src/qh.m2`, `toricResolve`).  Take the fan of the weighted blow-up of
  `A^n` at the origin, refine it to a smooth fan, and test the strict transform of `{f = 0}` chart by chart with the
  Jacobian criterion.  For an example this *constructs* a resolution, so its existence does not depend on any
  theorem except the toric properness criterion; for surfaces the resolution graph and self-intersections are
  computed and compared with the prediction from step 6.  When `f` is Newton non-degenerate and `k` is perfect this is
  what Aroca-Gomez-Morales-Mourtada, Thm 1.3, leads one to expect; the hypothesis "subdivision compatible with the
  Groebner fan of f" of that theorem is **not** checked, and the code does not use the theorem: everything is
  verified chart by chart.  Newton non-degeneracy as tested in `qhReport` means that, for every weight vector `v` in the closed orthant, the initial form `In_v(f)` has no singular point on the torus, with the Jacobian taken over `F_p`; I did not compare this with the definition of Aroca et al. line by line.  It is stronger than (A4), but all 361 (A4) samples of the recorded corpus happen to be
  Newton non-degenerate, so the corpus says nothing about the degenerate case.  My working notes record a random search
  (780 candidates with (A4), non-convenient or degenerate by an earlier, coarser test; characteristics 2, 3, 5) in which
  route 1 always succeeded; the raw logs are not part of this repository (`scripts/random_search.m2` regenerates
  such a search), so I do not count it as evidence here.
* **Route 2: stacky** (`package/ToricDestackification.m2`, `src/bergh_local.m2`).  Run Bergh's Algorithms A and B on the
  local toric model `[A^{n-1}/mu_r]` of each stratum.  This is the algorithm behind step 5, restricted to the
  toric local models; it does not need Newton non-degeneracy.

## 5. What is and is not verified

Verified by computation (see [CATALOG.md](CATALOG.md) for the individual cases):

* 361 samples satisfying (A4) (characteristics 2, 3, 5, 7, dimensions 2 to 6) with verdict CONFIRM: strict transform
  smooth in every chart, toric map proper, isomorphism off the origin.  For the 302 surfaces among them the resolution
  graph also agrees with the prediction of step 6; for the 59 samples of dimension >= 3 no prediction is compared by
  the code, only those three checks were made.  79 samples where (A4) fails are skipped.  No sample disagrees.
* For 11 samples an independent certificate exists (`data/certificates/`): smoothness of the strict transform,
  normal crossings of the exceptional locus, exact properness, an isomorphism off the vertex, with 696 unit-ideal
  identities re-expanded by an independent Python script and projectivity of the toric variety decided by exact
  rational linear programming.
* Bergh's algorithm reproduces the Hirzebruch-Jung chain for all 79 cyclic quotient singularities `1/r(1,q)`,
  `r <= 16`.

**Not** verified or **not** claimed:

* Statement M in general: it rests on the cited theorems and on steps 1 to 4, which are my derivations.
* That the resolution is minimal, `G_m`-equivariant, or projective over `X` (for the 11 certified samples the
  toric variety is projective; this is not claimed in general).
* The version of M for "regular" instead of "smooth over k" (non-perfect `k`).  For `k` finitely generated over
  `F_p` I sketched an argument by spreading out, `notes-ja/statements.md` L6, unreviewed; for a general `k` it is open to me.
* Termination of Algorithm B in practice: step A2 of Bergh's algorithm leaves four choices open (the order of a
  formal sum); the code exposes them as switches.  For surfaces, and for a rank-3 cone of multiplicity 3, all 16
  readings give the same correct result; for the rank-3 cone `(1,2,5)` only some readings finish in reasonable time
  (see the catalog).  The theory says every reading terminates; I cannot confirm that for the readings that did not
  finish in the time limit.
* Anything about non-isolated singularities, or about positive-dimensional strata beyond what the examples show.

## 6. Glossary of the labels used in code and tables

| label | meaning |
|---|---|
| (A4) | `X \ {v}` is smooth over `k` (isolatedness, for a hypersurface the Jacobian condition) |
| stratum | locus in `Y = Proj R` where the stabiliser `mu_r` is non-trivial; `K` = set of coordinates that do not vanish there |
| `p|w_i`, `p|d`, `p|r` | `p` divides a weight, the degree, or the order of some stabiliser |
| arm | one of the branches of the star-shaped dual graph of a surface resolution, attached to the central curve (the image of `Proj R`) |
| CONFIRM / SKIP | verdicts of `qhVerify`: prediction and explicit resolution agree / hypothesis (A4) fails so M does not apply |
| route 1, route 2 | the two computational routes of section 4 |
| stacky fan, label | combinatorial datum of a toric stack: a fan, and on each ray a positive integer (the multiple of the primitive generator which the structure map selects) |
