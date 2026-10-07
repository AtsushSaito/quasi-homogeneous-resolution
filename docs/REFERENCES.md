# References and how each was checked

Checking status, as of 2026-10-07:

* **text compared**: the statement quoted or paraphrased here was compared with the text of the arXiv PDF
  (automatic text extraction) by the AI assistant that helped write this repository.  The arXiv version can differ
  from the published one; theorem numbers should be re-checked against the journal version before they are quoted
  elsewhere.  *The author of this repository has not independently re-read these sources.*
* **metadata checked**: title, authors and journal reference agree with the arXiv listing.
* **not checked**: I did not look at the source; the citation is from memory or from a secondary source and may be
  inexact.  Treat as pointers only.

## Sources the main argument depends on

* **D. Bergh**, *Functorial destackification of tame stacks with abelian stabilisers*, Compositio Math. 153 (2017),
  1257-1315, arXiv:1409.5713.  *Metadata checked.*  *Text compared:* Definition 2.1 (standard pair; the divisor may
  be empty), Definition 2.3 (destackification), Theorem 1.2 (functorial destackification for a standard pair whose
  stack has diagonalisable stabilisers; the coarse space of the last stack is smooth), Corollary 1.3 (desingularisation
  of algebraic spaces of finite type over a field with simplicial toric singularities: a sequence of proper birational
  modifications with smooth end), the definition of simplicial toric singularities (page 3), Definition 2.6
  (distinguished divisors), Definitions 3.2, 3.5, 3.8 (stacky fan, star subdivision, independent ray), Theorem A.1 and
  Proposition A.8, Example 4.1, Algorithms A and B (section 4).  Bergh defines tame as "finite inertia and linearly
  reductive stabilisers" (page 5) and, in Appendix A, as exactness of the coarse pushforward (equivalent under finite
  inertia by A.1).
  *Not found in the text:* a statement that the blow-up centres avoid the locus of trivial stabilisers (see
  [MATH.md](MATH.md), step 5).
* **D. Abramovich, M. Olsson, A. Vistoli**, *Tame stacks in positive characteristic*, Ann. Inst. Fourier 58 (2008),
  arXiv:math/0703310.  *Text compared:* Proposition 2.10 (locally well-split group schemes are linearly reductive),
  Proposition 2.13 (over a field, finite linearly reductive iff locally well-split), the remark that the only
  non-trivial local abelian group schemes without proper subgroups are `alpha_p` and `mu_p`, and that `alpha_p` is
  not linearly reductive.  Metadata not re-checked beyond the arXiv listing.
* **J. Wlodarczyk**, *Functorial resolution by torus actions*, arXiv:2203.03090 (the numbering below is that of v4).  *Metadata checked (no journal
  reference in the listing).*  *Text compared:* Definition 4.2.1 (almost homogeneous singularity), Theorem 4.2.2 (under
  that hypothesis, and if `X` is universally catenary or every component of the weighted normal cone outside `Z` has the
  expected codimension, the cobordant blow-up resolves `Y`: the strict transform is regular), Example 4.4.3 (a Brieskorn
  hypersurface `sum alpha_i x_i^{c_i}`: in positive characteristic, if the singular locus lies in `V(x_1, ..., x_k)`, one
  cobordant blow-up after removing the vertex suffices; "over non-perfect fields, the general case remains a challenging
  and unresolved problem").  Note: Theorem 4.2.2 is about the cobordant blow-up, a scheme with a torus action whose
  quotient is the weighted blow-up, not about the quotient itself; the quotient singularities are then resolved by
  other results (Wlodarczyk cites Bergh-Rydh).  Example 4.4.3 is about Brieskorn-type equations only.
* **D. Bergh, D. Rydh**, *Functorial destackification and weak factorization of orbifolds*, arXiv:1905.00872.
  *Metadata checked.*  Abstract only; it assumes a smooth stack.  Not used in any argument here.
* **M. Satriano**, *The Chevalley-Shephard-Todd theorem for finite linearly reductive group schemes*, Algebra &
  Number Theory 6 (2012), 1-26, arXiv:0911.2058.  *Text compared:* Corollary 1.8 and the first paragraph of its proof:
  for a smooth affine `U` over a field `k` with a faithful action of a finite linearly reductive group scheme `G`, and a
  `G`-fixed point `x`, a `G`-equivariant section of `m_x -> m_x/m_x^2` gives a `G`-equivariant isomorphism
  `k[[V]] -> O^_{U,x}` (the proof first reduces to a `k`-rational point by a separable extension).  Used for the
  local linearisation behind the predicted local types (step 6 of MATH.md), not for the main existence argument.
  (Bergh refers to Satriano and to Vistoli for the canonical stack of a variety with simplicial toric singularities.)
* **F. Aroca, M. Gomez-Morales, H. Mourtada**, *Groebner fan and embedded resolutions of ideals on toric varieties*,
  Beitr. Algebra Geom. (2023), arXiv:2202.10874.  *Text compared:* Theorem 1.3 (for a Newton non-degenerate ideal `J`
  and a regular subdivision of the cone compatible with the Groebner fan of `J`, the toric morphism is proper
  birational, the components of the total transform are smooth and meet transversally, in particular the strict
  transform is smooth), Remark 1.4 (the statement is local, "in a small neighbourhood of O"), and that `K` is a perfect
  field throughout.  The journal reference is from memory, not from the arXiv listing.
* **D. Cox, J. Little, H. Schenck**, *Toric Varieties*, AMS GSM 124, 2011, Theorem 3.4.11 (a toric morphism is proper
  iff the preimage of the support of the target fan is the support of the source fan).  *Not checked* in this session;
  the theorem number comes from my earlier notes.  For properness of the maps in the examples the code uses the exact
  combinatorial form of this criterion and does not rely on a printed statement.

## Classical results used as expected values in the catalog (not checked)

* **M. Artin**, *On isolated rational singularities of surfaces*, Amer. J. Math. 88 (1966): the resolution graph of a
  rational double point is an ADE Dynkin diagram.  The identification of the char-`p` normal forms (including the
  forms `D_n^0`, `E_n^0` in characteristic 2) is Artin's *Coverings of the rational double points in characteristic p*
  (in: Complex Analysis and Algebraic Geometry, 1977, pp. 11-22); for the forms used here I relied on **Y. Matsumoto**,
  *Purely inseparable coverings of rational double points in positive characteristic*, J. Singul. 24 (2022), 79-95,
  arXiv:2003.10344 (Table 1).  *Metadata of Matsumoto checked; Artin's papers not seen.*
* **Hirzebruch-Jung continued fractions** for cyclic quotient surface singularities: e.g. Cox-Little-Schenck,
  *Toric Varieties*, Chapter 10 (chapter number not re-checked), or Fulton, *Introduction to Toric Varieties*,
  section 2.6.  The catalog computes them independently in exact integer arithmetic.
* **Simple elliptic singularities** `E~6, E~7, E~8`: one elliptic curve with self-intersection `-3, -2, -1`
  (K. Saito 1974, Laufer; characteristic 0).  *Not checked*; in characteristic `p` the catalog compares the computation with
  this value and the values agree where (A4) holds.
* **Pinkham, H.**, *Normal surface singularities with C^* action*, Math. Ann. 227 (1977), 183-193, and **Orlik, P.,
  Wagreich, P.**, *Isolated singularities of algebraic surfaces with C^* action*, Ann. of Math. 93 (1971), 205-228:
  the shape of the resolution graph and the formula for the self-intersection of the central curve, which
  `qhPredict` implements for surfaces.  *Not checked*; the formula is verified here only by agreement with the explicit
  resolution on 279 surfaces (my working notes).
* **Arnold's exceptional unimodal singularities**: the quasi-homogeneous representatives in `src/corpus.m2` are
  standard; the weights were recomputed here.  *Not checked against a table.*

## Other works mentioned in the notes

Cossart-Piltant (threefolds in positive characteristic), Lipman (surfaces), Hauser (survey), Kempf-Knudsen-Mumford-Saint-Donat
(toroidal embeddings), Varchenko (Newton non-degeneracy in characteristic 0), Alper-Hall-Rydh and Liedtke-Martin-Matsumoto
(linearisation of actions, `arXiv:1504.06467` and `arXiv:2102.01067`, both assuming an algebraically closed field)
appear in my working notes.  None is used in an argument of this repository, and I did not check the citations.

## Prior implementations

I searched the Macaulay2 documentation, the Sage documentation, the polymake documentation and the OSCAR toric
paper for an implementation of Bergh's destackification and did not find one.  This is a search of limited scope on
one day; it does not show that none exists, and I did not search other software or private code.
