newPackage(
    "ToricDestackification",
    Version => "0.1",
    Date => "September 9, 2026",
    Authors => {{Name => "Atsushi Saito"}},
    Headline => "toric stacky fans and Bergh's destackification algorithm",
    Keywords => {"Toric Geometry"},
    DebuggingMode => false
    )

export {
    "StackyFan", "stackyFan", "stackyRays", "stackyLabels", "maximalCones", "distinguishedRays",
    "coneMultiplicity", "conesOfStackyFan", "parallelotopeLattice", "isIndependentRay",
    "starSubdivision", "rootConstruction", "partialDestackify", "destackify",
    "isSmoothStackyFan", "basicToricStackyFan", "resolutionChain", "contractMinusOneCurves",
    "hirzebruchJung", "MaxIterations"
    }

-- ============================================================ helpers (not exported)

gcdList := L -> if #L == 0 then 0 else fold(L, gcd);
lcmList := L -> if #L == 0 then 1 else fold(L, lcm);
vplus := (a, b) -> apply(a, b, plus);
vscale := (c, a) -> apply(a, x -> c*x);
cartesianProduct := L -> (
    if #L == 0 then return {{}};
    rest := cartesianProduct drop(L, 1);
    flatten apply(L#0, a -> apply(rest, t -> prepend(a, t))));
lexLess := (a, b) -> (
    for i from 0 to #a - 1 do (
        if a#i < b#i then return true;
        if a#i > b#i then return false);
    false);
psiLess := (a, b) -> lexLess(reverse a, reverse b);
psiVector := (psi, nr) -> apply(nr, i -> if psi#?i then psi#i else 0);

-- ============================================================ the type

StackyFan = new Type of MutableHashTable
StackyFan.synonym = "stacky fan"

stackyFan = method()
stackyFan (List, List, List) := StackyFan => (rys, lbls, cns) -> (
    if #rys == 0 then error "stackyFan: expected at least one ray";
    n := #(rys#0);
    if not all(rys, r -> #r == n) then error "stackyFan: rays must all have the same length";
    if #lbls =!= #rys then error "stackyFan: expected one label per ray";
    if not all(lbls, l -> instance(l, ZZ) and l > 0) then error "stackyFan: labels must be positive integers";
    if not all(cns, c -> instance(c, List) and #c > 0) then error "stackyFan: each cone must be a non-empty list of ray indices";
    if not all(cns, c -> all(c, i -> instance(i, ZZ) and i >= 0 and i < #rys))
    then error "stackyFan: cone entries must be indices of rays of the fan";
    if not all(cns, c -> #(unique c) == #c) then error "stackyFan: a cone must not repeat a ray";
    new StackyFan from {
        "rays" => rys, "labels" => lbls, "maxCones" => unique apply(cns, c -> sort c),
        "dist" => {}, "log" => {}, "multCache" => new MutableHashTable})

net StackyFan := F -> net("stacky fan with " | toString(#F#"rays") | " rays and " |
    toString(#F#"maxCones") | " maximal cones")

stackyRays = method()
stackyRays StackyFan := List => F -> F#"rays"

stackyLabels = method()
stackyLabels StackyFan := List => F -> F#"labels"

maximalCones = method()
maximalCones StackyFan := List => F -> F#"maxCones"

distinguishedRays = method()
distinguishedRays StackyFan := List => F -> sort F#"dist"

conesOfStackyFan = method()
conesOfStackyFan StackyFan := List => F -> unique flatten apply(F#"maxCones", c -> subsets c)

-- ============================================================ multiplicity and independency

coneMultiplicity = method()
coneMultiplicity (StackyFan, List) := ZZ => (F, sigma) -> (
    if #sigma == 0 then return 1;
    key := sort sigma;
    cache := F#"multCache";
    if cache#?key then return cache#key;
    U := matrix apply(key, i -> F#"rays"#i);
    -- Dependent rays give an empty maximal-minors ideal and a multiplicity of 0.  Both algorithms
    -- filter on multiplicity greater than one, so such a cone would be skipped and the loop would
    -- report success on a fan that is not smooth.
    if rank U != #key then error("coneMultiplicity: the rays of the cone are linearly dependent");
    m := abs gcdList flatten entries gens minors(#key, U);
    cache#key = m;
    m)

parallelotopeLattice = method()
parallelotopeLattice (StackyFan, List) := List => (F, sigma) -> (
    r := #sigma;
    if r == 0 then return {{}};
    U := matrix apply(sigma, i -> F#"rays"#i);
    (D, P, Q) := smithNormalForm(U, ChangeMatrix => {true, true});
    ds := apply(r, i -> D_(i,i));
    if any(ds, d -> d == 0) then error "parallelotopeLattice: the cone is not simplicial";
    Pq := promote(P, QQ);
    unique apply(cartesianProduct apply(ds, d -> toList(0 .. d-1)), tup -> (
        nu := matrix {apply(r, i -> (tup#i) / (ds#i))};
        apply(flatten entries (nu * Pq), x -> x - floor x))))

interiorLattice := (F, sigma) -> select(parallelotopeLattice(F, sigma), lam -> all(lam, x -> x > 0))

isIndependentRay = method()
isIndependentRay (StackyFan, List, ZZ) := Boolean => (F, sigma, rho) ->
    coneMultiplicity(F, select(sigma, i -> i != rho)) == coneMultiplicity(F, sigma)

isSmoothStackyFan = method()
isSmoothStackyFan StackyFan := Boolean => F -> all(F#"maxCones", c -> coneMultiplicity(F, c) == 1)

-- ============================================================ the two modifications

starSubdivision = method()
starSubdivision (StackyFan, List) := ZZ => (F, sigma) -> (
    if #sigma == 0 then error "starSubdivision: expected a non-empty cone";
    if not all(sigma, i -> instance(i, ZZ) and i >= 0 and i < #F#"rays")
    then error "starSubdivision: the cone must be given by indices of rays of the fan";
    if #(unique sigma) != #sigma then error "starSubdivision: the cone must not repeat a ray";
    -- Without this the call silently appends a ray that no cone contains, and logs a subdivision
    -- that did not happen: the loop below only rewrites cones that contain sigma.
    if not any(F#"maxCones", c -> isSubset(sigma, c))
    then error "starSubdivision: the cone is not a face of any maximal cone";
    n := #(F#"rays"#0);
    v := fold(apply(sigma, i -> vscale(F#"labels"#i, F#"rays"#i)), vplus);
    g := gcdList v;
    u := apply(v, x -> x // g);
    ni := position(F#"rays", x -> x == u);
    if ni === null then (
        F#"rays" = append(F#"rays", u);
        F#"labels" = append(F#"labels", g);
        ni = #F#"rays" - 1)
    else (
        if F#"labels"#ni != g then error "starSubdivision: the new ray already exists with a different label";
        if member(ni, sigma) then error "starSubdivision: the new ray is already a ray of the cone");
    newMax := {};
    for c in F#"maxCones" do
        if isSubset(sigma, c) then
            for rho in sigma do newMax = append(newMax, sort append(select(c, i -> i != rho), ni))
        else newMax = append(newMax, c);
    F#"maxCones" = unique newMax;
    F#"log" = append(F#"log", ("star", sigma, u, g));
    ni)

rootConstruction = method()
rootConstruction (StackyFan, List, List) := StackyFan => (F, rhos, ds) -> (
    if #rhos =!= #ds then error "rootConstruction: expected one weight per ray";
    if not all(rhos, i -> instance(i, ZZ) and i >= 0 and i < #F#"rays")
    then error "rootConstruction: the rays must be given by indices of rays of the fan";
    if #(unique rhos) != #rhos then error "rootConstruction: a ray must not appear twice";
    -- Labels are positive by construction and every other operation relies on it; a weight of
    -- zero or less would put the fan into a state stackyFan itself rejects.
    if not all(ds, d -> instance(d, ZZ) and d > 0)
    then error "rootConstruction: the weights must be positive integers";
    lb := new MutableList from F#"labels";
    for k from 0 to #rhos - 1 do lb#(rhos#k) = lb#(rhos#k) * (ds#k);
    F#"labels" = toList lb;
    F#"log" = append(F#"log", ("root", rhos, ds));
    F)

betaOf := (F, psi) -> fold(apply(sort keys psi, i -> vscale(psi#i * F#"labels"#i, F#"rays"#i)), vplus)

-- ============================================================ Algorithms A and B

partialDestackify = method(Options => {MaxIterations => 5000, Verbose => false})
partialDestackify StackyFan := StackyFan => opts -> F -> (
    iter := 0;
    while true do (
        iter = iter + 1;
        if iter > opts.MaxIterations then error "partialDestackify: iteration limit exceeded";
        S := select(conesOfStackyFan F, sigma -> #sigma > 0
                and any(sigma, i -> member(i, F#"dist"))
                and coneMultiplicity(F, sigma) > 1
                and #(interiorLattice(F, sigma)) > 0);
        if #S == 0 then break;
        keyOf := sigma -> {#select(sigma, i -> not member(i, F#"dist")), coneMultiplicity(F, sigma)};
        best := keyOf S#0;
        for sigma in S do if lexLess(best, keyOf sigma) then best = keyOf sigma;
        Smax := select(S, sigma -> keyOf sigma == best);
        cands := {};
        for sigma in Smax do for lam in interiorLattice(F, sigma) do (
            m := lcmList apply(lam, x -> denominator x);
            as := apply(lam, x -> lift(x * m, ZZ));
            ls := apply(sigma, i -> F#"labels"#i);
            s := lcmList apply(#sigma, j -> (ls#j) // gcd(as#j, ls#j));
            cs := apply(#sigma, j -> s * (as#j) // (ls#j));
            cands = append(cands, new HashTable from apply(#sigma, j -> sigma#j => cs#j)));
        nr := #F#"rays";
        vecs := apply(cands, p -> psiVector(p, nr));
        bi := 0;
        for j from 1 to #vecs - 1 do if psiLess(vecs#j, vecs#bi) then bi = j;
        psi := cands#bi;
        b0 := betaOf(F, psi);
        supp := sort keys psi;
        distIn := select(supp, i -> member(i, F#"dist"));
        if #distIn > 0 then (
            rootConstruction(F, distIn, apply(distIn, i -> psi#i));
            psi = new HashTable from (
                apply(select(supp, i -> not member(i, F#"dist")), i -> i => psi#i) |
                apply(distIn, i -> i => 1));
            if betaOf(F, psi) != b0 then error "partialDestackify: the root step broke beta(psi)");
        while #(keys psi) > 1 do (
            sig := sort keys psi;
            eps := starSubdivision(F, sig);
            F#"dist" = unique append(F#"dist", eps);
            newpsi := select(apply(sig, i -> i => psi#i - 1), pr -> pr#1 > 0);
            psi = new HashTable from append(newpsi, eps => 1);
            if betaOf(F, psi) != b0 then error "partialDestackify: the subdivision broke beta(psi)";
            if opts.Verbose then << "  subdivided " << sig << endl));
    F)

partialDestackify (StackyFan, List) := StackyFan => opts -> (F, D) -> (
    if not all(D, i -> instance(i, ZZ) and i >= 0 and i < #F#"rays")
    then error "partialDestackify: the distinguished rays must be indices of rays of the fan";
    F#"dist" = sort unique D;
    partialDestackify(F, MaxIterations => opts.MaxIterations, Verbose => opts.Verbose))

destackify = method(Options => {MaxIterations => 5000, Verbose => false})
destackify StackyFan := StackyFan => opts -> F -> (
    iter := 0;
    while true do (
        iter = iter + 1;
        if iter > opts.MaxIterations then error "destackify: iteration limit exceeded";
        S := select(conesOfStackyFan F, sigma -> #sigma > 0
                and coneMultiplicity(F, sigma) > 1
                and not any(sigma, rho -> isIndependentRay(F, sigma, rho)));
        if #S == 0 then break;
        dmax := max apply(S, s -> #s);
        sigma := last sort select(S, s -> #s == dmax);
        if opts.Verbose then << "cone " << sigma << " of multiplicity " << coneMultiplicity(F, sigma) << endl;
        eps := starSubdivision(F, sigma);
        F#"dist" = {eps};
        partialDestackify(F, MaxIterations => opts.MaxIterations, Verbose => opts.Verbose);
        F#"dist" = {});
    F)

-- ============================================================ basic toric stacks and surfaces

basicToricStackyFan = method()
basicToricStackyFan (ZZ, List) := StackyFan => (r, a) -> (
    if r < 1 then error "basicToricStackyFan: expected a positive order";
    m := #a;
    M := matrix(apply(m, i -> apply(m, j -> if i == j then r else 0)) | {toList a});
    (D, P, Q) := smithNormalForm(M, ChangeMatrix => {true, true});
    ds := apply(m, i -> D_(i,i));
    B := (diagonalMatrix ds) * inverse promote(Q, QQ);
    Binv := inverse B;
    rys := {}; lbls := {};
    for i from 0 to m - 1 do (
        x := flatten entries ((matrix {apply(m, j -> if j == i then r else 0)}) * Binv);
        if any(x, t -> denominator t != 1) then error "basicToricStackyFan: non-integral coordinate";
        xz := apply(x, t -> lift(t, ZZ));
        g := gcdList xz;
        rys = append(rys, apply(xz, t -> t // g));
        lbls = append(lbls, g));
    stackyFan(rys, lbls, {toList(0 .. m-1)}))

resolutionChain = method()
resolutionChain StackyFan := List => F -> (
    if #(F#"rays"#0) != 2 then error "resolutionChain: only defined for a rank two lattice";
    adj := new MutableHashTable;
    for i from 0 to #F#"rays" - 1 do adj#i = {};
    for c in F#"maxCones" do (
        if #c != 2 then continue;
        adj#(c#0) = append(adj#(c#0), c#1);
        adj#(c#1) = append(adj#(c#1), c#0));
    -- Sort: adj is a MutableHashTable and M2 does not specify the order of its keys, so an
    -- unsorted endpoint would make the orientation of the returned chain depend on hashing.
    ends := sort select(select(keys adj, i -> #(adj#i) > 0), i -> #(adj#i) == 1);
    if #ends != 2 then error "resolutionChain: the fan is not a path";
    path := {first ends}; prev := -1; cur := first ends;
    while true do (
        nx := select(adj#cur, j -> j != prev);
        if #nx == 0 then break;
        prev = cur; cur = first nx; path = append(path, cur));
    if #path != #(select(keys adj, i -> #(adj#i) > 0))
    then error "resolutionChain: the rays with edges do not form a single path";
    apply(#path - 2, k -> (
        vm := F#"rays"#(path#k); v := F#"rays"#(path#(k+1)); vp := F#"rays"#(path#(k+2));
        s := vplus(vm, vp);
        idx := position(v, t -> t != 0);
        if s#idx % v#idx != 0 then error "resolutionChain: non-integral self-intersection";
        b := s#idx // v#idx;
        if vplus(s, vscale(-b, v)) != {0, 0} then error "resolutionChain: the fan is not smooth";
        b)))

contractMinusOneCurves = method()
contractMinusOneCurves List := List => bs -> (
    L := bs;
    while true do (
        j := position(L, b -> b == 1);
        if j === null then break;
        if j > 0 then L = replace(j-1, L#(j-1) - 1, L);
        if j < #L - 1 then L = replace(j+1, L#(j+1) - 1, L);
        L = drop(L, {j, j}));
    L)

hirzebruchJung = method()
hirzebruchJung (ZZ, ZZ) := List => (r, q) -> (
    if r < 1 or q < 0 then error "hirzebruchJung: expected r > 0 and q >= 0";
    L := {}; rr := r; qq := q;
    while qq > 0 do (b := ceiling(rr / qq); L = append(L, b); (rr, qq) = (qq, b*qq - rr));
    L)

beginDocumentation()

doc ///
  Key
    ToricDestackification
  Headline
    toric stacky fans and Bergh's destackification algorithm
  Description
    Text
      A stacky fan records a fan together with a choice of lattice point on each ray.  It is the
      combinatorial datum behind a toric stack, in the sense of Definition 3.2 of Daniel Bergh,
      {\em Functorial destackification of tame stacks with abelian stabilisers}, Compositio
      Mathematica 153 (2017) 1257-1315.  Over a free lattice such a datum is faithfully recorded by
      the primitive generator of each ray together with a positive integer label, the multiple of
      that generator which the structure map picks out.
    Text
      This package implements the two modifications of stacky fans, the star subdivision and the
      root construction, and Bergh's Algorithms A and B, which remove stackiness by repeatedly
      applying them.  Everything here is integer arithmetic: no field, no polynomial and no
      characteristic appears, which is why the algorithm works uniformly in every characteristic.
    Text
      The output of @TO destackify@ has a smooth coarse space.  Labels larger than one may remain;
      they record the root stack structure and do not obstruct smoothness of the coarse space.  The
      algorithm optimises for functoriality rather than economy, so it does not produce minimal
      resolutions; for surfaces, @TO contractMinusOneCurves@ recovers the minimal chain, which
      agrees with the Hirzebruch-Jung continued fraction of @TO hirzebruchJung@.
    Example
      F = stackyFan({{0,1},{5,-2}}, {1,1}, {{0,1}});
      coneMultiplicity(F, {0,1})
      destackify F;
      isSmoothStackyFan F
      contractMinusOneCurves resolutionChain F
      hirzebruchJung(5, 2)
    Text
      The coarse space of the result is an ordinary toric variety, so it can be handed straight to
      @TO "NormalToricVarieties::NormalToricVarieties"@.  Nothing in this package depends on that
      one; the rays and cones are all it needs.
    Example
      needsPackage "NormalToricVarieties";
      F = stackyFan({{0,1},{5,-2}}, {1,1}, {{0,1}});
      destackify F;
      X = normalToricVariety(stackyRays F, maximalCones F);
      isSmooth X
      stackyLabels F
    Text
      The labels are what the coarse space forgets.  A label larger than one on a ray says the
      stack has a cyclic gerbe-like structure along the corresponding divisor, which is invisible
      to @TO "NormalToricVarieties::normalToricVariety"@ and is why the coarse space can be smooth
      while the stack is not a scheme.
  Caveat
    The lattice is assumed to be free.
    
    One choice in Bergh's step A2 is not determined by the paper: it takes the formal sum of rays
    that is smallest for "the lexicographic ordering", and since the rays are ordered with new
    ones appended, a sum can be compared with the earliest ray most significant or the latest.
    This implementation takes the latest.
    
    As I read Bergh's termination argument, it uses only that the ray through the chosen sum
    meets a lattice point of the parallelotope, not that the sum is the lexicographic least, so
    any element of the candidate set should lead to termination with a valid result; the ordering
    is there to make the choice canonical, and hence the algorithm functorial.  I have not
    verified this for every reading: with a time limit of 200 seconds some readings did not
    finish.  The choice does affect cost, sharply: on the cone spanned by e_1, e_2 and (1,2,5)
    taking the latest ray as most significant finishes in a few seconds with 85 rays, while taking
    the earliest exceeded 200 seconds in the runs made, with intermediate multiplicities above 30000.
    
    The package implements this one fixed reading of step A2.  Functoriality of Bergh's construction is a
    property of the paper's algorithm; I have not verified that it holds for the reading chosen here.

    Everything else follows the paper as written.  The cones are ordered first by the number of
    non-distinguished extremal rays and then by the multiplicity, and the maximal ones are taken;
    the lattice points considered are those in the relative interior of the parallelotope, which
    is also what the termination argument needs, since it requires the cone generated by the
    support of the chosen sum to be one of the maximal cones.
  SeeAlso
    destackify
    basicToricStackyFan
///

doc ///
  Key
    StackyFan
  Headline
    the class of stacky fans over a free lattice
  Description
    Text
      An object of this class stores the primitive generator of each ray, a positive integer label
      per ray, the maximal cones as lists of ray indices, and the set of distinguished rays used by
      @TO partialDestackify@.  Build one with @TO stackyFan@ or @TO basicToricStackyFan@.
  SeeAlso
    stackyFan
///

doc ///
  Key
    stackyFan
    (stackyFan, List, List, List)
  Headline
    make a stacky fan from rays, labels and maximal cones
  Usage
    F = stackyFan(rayList, labelList, coneList)
  Inputs
    rayList:List
      the primitive generator of each ray, as a list of integer vectors of equal length
    labelList:List
      one positive integer per ray; the structure map sends the ray to this multiple of its
      primitive generator
    coneList:List
      the maximal cones, each a list of indices into {\tt rayList}
  Outputs
    F:StackyFan
  Description
    Text
      The order of the rays is part of the data: Bergh's algorithms break ties using it.
    Example
      F = stackyFan({{0,1},{5,-2}}, {1,1}, {{0,1}});
      stackyRays F
      coneMultiplicity(F, {0,1})
  SeeAlso
    basicToricStackyFan
///

doc ///
  Key
    (stackyRays, StackyFan)
    stackyRays
    (stackyLabels, StackyFan)
    stackyLabels
    (maximalCones, StackyFan)
    maximalCones
    (distinguishedRays, StackyFan)
    distinguishedRays
    (conesOfStackyFan, StackyFan)
    conesOfStackyFan
  Headline
    the parts of a stacky fan
  Usage
    stackyRays F
    stackyLabels F
    maximalCones F
    distinguishedRays F
    conesOfStackyFan F
  Inputs
    F:StackyFan
  Outputs
    :List
  Description
    Text
      The first three return the primitive generators, the labels and the maximal cones.  The
      fourth returns the rays currently marked distinguished, in the sense of Definition 2.6 of
      Bergh.  The last returns every cone of the fan, that is, every subset of a maximal cone,
      which is what the algorithms iterate over.
    Example
      F = basicToricStackyFan(3, {1,2});
      stackyRays F
      stackyLabels F
      #conesOfStackyFan F
///

doc ///
  Key
    coneMultiplicity
    (coneMultiplicity, StackyFan, List)
  Headline
    the multiplicity of a cone
  Usage
    m = coneMultiplicity(F, sigma)
  Inputs
    F:StackyFan
    sigma:List
      a cone, given as a list of ray indices
  Outputs
    m:ZZ
  Description
    Text
      The multiplicity is the number of lattice points of the half open parallelotope spanned by
      the {\em primitive} generators, equivalently the greatest common divisor of the maximal
      minors of the matrix of those generators.  The labels play no part, so the multiplicity is
      unchanged by @TO rootConstruction@.  A cone is smooth exactly when its multiplicity is one.
    Example
      F = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
      coneMultiplicity(F, {0,1})
      coneMultiplicity(F, {0})
  SeeAlso
    isSmoothStackyFan
///

doc ///
  Key
    parallelotopeLattice
    (parallelotopeLattice, StackyFan, List)
  Headline
    the lattice points of the parallelotope of a cone
  Usage
    L = parallelotopeLattice(F, sigma)
  Inputs
    F:StackyFan
    sigma:List
  Outputs
    L:List
      each entry a list of rationals in [0,1), the coefficients of a lattice point with respect to
      the primitive generators of the cone
  Description
    Text
      The number of points returned is the multiplicity of the cone.
    Example
      F = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
      parallelotopeLattice(F, {0,1})
  SeeAlso
    coneMultiplicity
///

doc ///
  Key
    isIndependentRay
    (isIndependentRay, StackyFan, List, ZZ)
  Headline
    whether a ray is independent at a cone
  Usage
    isIndependentRay(F, sigma, rho)
  Inputs
    F:StackyFan
    sigma:List
    rho:ZZ
      the index of a ray of {\tt sigma}
  Outputs
    :Boolean
  Description
    Text
      Following Definition 3.8 of Bergh, the ray is independent at the cone when removing it does
      not change the multiplicity.  Algorithm B terminates exactly when every ray is independent at
      every cone, which happens precisely when every cone is smooth.
    Example
      F = basicToricStackyFan(3, {1,2});
      isIndependentRay(F, {0,1}, 0)
      destackify F;
      all(maximalCones F, c -> all(c, r -> isIndependentRay(F, c, r)))
///

doc ///
  Key
    starSubdivision
    (starSubdivision, StackyFan, List)
  Headline
    subdivide a stacky fan at a cone
  Usage
    i = starSubdivision(F, sigma)
  Inputs
    F:StackyFan
    sigma:List
  Outputs
    i:ZZ
      the index of the new exceptional ray
  Description
    Text
      Following Definition 3.5 of Bergh, the new ray is generated by the sum of the labelled
      generators of the rays of the cone, and the structure map sends it to that sum.  The new ray
      therefore carries the label needed to make the sum primitive, which need not be one.  The
      fan is modified in place.
    Example
      F = stackyFan({{0,1},{3,-1}}, {1,1}, {{0,1}});
      starSubdivision(F, {0,1})
      stackyRays F
      stackyLabels F
  SeeAlso
    rootConstruction
///

doc ///
  Key
    rootConstruction
    (rootConstruction, StackyFan, List, List)
  Headline
    take roots along a set of rays
  Usage
    rootConstruction(F, rayIndices, weights)
  Inputs
    F:StackyFan
    rayIndices:List
    weights:List
      one positive integer per ray
  Outputs
    :StackyFan
  Description
    Text
      Following Definition 3.6 of Bergh, the structure map is multiplied by the given weight on
      each listed ray.  In this presentation that means multiplying the label.  Multiplicities are
      unchanged, so the coarse space does not move; only the stacky structure does.  The fan is
      modified in place.
    Example
      F = stackyFan({{1,0},{0,1}}, {1,1}, {{0,1}});
      rootConstruction(F, {0}, {3});
      stackyLabels F
      coneMultiplicity(F, {0,1})
///

doc ///
  Key
    partialDestackify
    (partialDestackify, StackyFan)
    (partialDestackify, StackyFan, List)
    [partialDestackify, MaxIterations]
    [partialDestackify, Verbose]
    MaxIterations
  Headline
    Bergh's Algorithm A, making the distinguished rays independent
  Usage
    partialDestackify F
    partialDestackify(F, D)
  Inputs
    F:StackyFan
    D:List
      the indices of the rays to mark distinguished; without it, the rays already marked are used
    MaxIterations => ZZ
      abort after this many iterations of the main loop
    Verbose => Boolean
      report each subdivision
  Outputs
    :StackyFan
  Description
    Text
      This is Algorithm A of Bergh.  It repeatedly picks a cone whose parallelotope has an interior
      lattice point and which meets the distinguished locus, takes roots so that the distinguished
      rays occur with coefficient one, and then subdivides.  On return every distinguished ray is
      independent at every cone containing it, in the sense of @TO isIndependentRay@.  Cones that
      meet no distinguished ray are left alone, so the result need not be smooth.
    Example
      F = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
      partialDestackify(F, {0});
      coneMultiplicity(F, {0,1})
      all(maximalCones F, c -> all(select(c, r -> member(r, distinguishedRays F)),
              r -> isIndependentRay(F, c, r)))
    Text
      With nothing distinguished there is nothing to do.  @TO destackify@ drives this by
      distinguishing the exceptional ray of each star subdivision it makes.
  SeeAlso
    destackify
    distinguishedRays
///

doc ///
  Key
    destackify
    (destackify, StackyFan)
    [destackify, MaxIterations]
    [destackify, Verbose]
  Headline
    Bergh's Algorithm B, making the coarse space smooth
  Usage
    destackify F
  Inputs
    F:StackyFan
    MaxIterations => ZZ
    Verbose => Boolean
  Outputs
    :StackyFan
  Description
    Text
      This is Algorithm B of Bergh.  On return every cone is smooth, so the coarse space of the
      corresponding toric stack is smooth.  Labels larger than one may remain: they record the
      root stack structure, and the coarse space does not see them.  The fan is modified in place.
    Text
      Algorithm B drives @TO partialDestackify@ by distinguishing the exceptional ray of each star
      subdivision it makes, so it owns the distinguished structure while it runs and clears it
      before returning.  Any marking set beforehand through @TO (partialDestackify, StackyFan, List)@
      is therefore ignored and does not survive the call: @TO distinguishedRays@ is empty
      afterwards.
    Example
      F = stackyFan({{0,1},{7,-3}}, {1,1}, {{0,1}});
      coneMultiplicity(F, {0,1})
      destackify F;
      isSmoothStackyFan F
      contractMinusOneCurves resolutionChain F
      hirzebruchJung(7, 3)
  Caveat
    The construction is functorial, not economical.  The number of rays it adds grows quickly with
    the multiplicity of the starting cone, and for a cone of multiplicity ten in rank two it
    produces a chain of several hundred curves before contraction.  In rank three and above it may
    fail to terminate within a reasonable time for multiplicity six and beyond.
  SeeAlso
    partialDestackify
    contractMinusOneCurves
///

doc ///
  Key
    isSmoothStackyFan
    (isSmoothStackyFan, StackyFan)
  Headline
    whether every cone is smooth
  Usage
    isSmoothStackyFan F
  Inputs
    F:StackyFan
  Outputs
    :Boolean
  Description
    Text
      True exactly when every maximal cone has multiplicity one, which is what @TO destackify@
      achieves.  Labels are not consulted.
    Example
      F = basicToricStackyFan(4, {1,1});
      isSmoothStackyFan F
      destackify F;
      isSmoothStackyFan F
///

doc ///
  Key
    basicToricStackyFan
    (basicToricStackyFan, ZZ, List)
  Headline
    the stacky fan of a quotient of affine space by a group of roots of unity
  Usage
    F = basicToricStackyFan(r, a)
  Inputs
    r:ZZ
      the order
    a:List
      the weights of the action, one per coordinate
  Outputs
    F:StackyFan
  Description
    Text
      Builds the stacky fan of the quotient stack of affine space of dimension the length of the
      weight list by the group scheme of {\tt r}-th roots of unity acting with the given weights.
      The result is expressed in a basis of the enlarged lattice, so a weight that acts as a
      pseudo-reflection shows up as a label rather than as a singularity.
    Example
      F = basicToricStackyFan(2, {1,1});
      coneMultiplicity(F, {0,1})
      G = basicToricStackyFan(2, {1,0});
      coneMultiplicity(G, {0,1})
      stackyLabels G
    Text
      In rank two the basis produced here presents the singularity of order {\tt r} and type
      {\tt q} in its inverse form, so the chain of exceptional curves comes out reversed relative
      to the Hirzebruch-Jung expansion of {\tt r/q}.  Both describe the same singularity.
    Example
      H = basicToricStackyFan(7, {1,3});
      destackify H;
      contractMinusOneCurves resolutionChain H
      hirzebruchJung(7, 5)
  SeeAlso
    destackify
///

doc ///
  Key
    resolutionChain
    (resolutionChain, StackyFan)
  Headline
    the self-intersection numbers of a chain of exceptional curves
  Usage
    bs = resolutionChain F
  Inputs
    F:StackyFan
      of rank two, smooth, whose rays form a path
  Outputs
    bs:List
      the integers whose negatives are the self-intersection numbers, in order along the chain
  Description
    Text
      For consecutive rays in a smooth rank two fan the middle one satisfies a relation with its
      neighbours, and the coefficient of that relation is the negative of the self-intersection of
      the corresponding curve.
    Example
      F = stackyFan({{0,1},{5,-2}}, {1,1}, {{0,1}});
      destackify F;
      contractMinusOneCurves resolutionChain F
    Text
      The chain has an orientation, and which end comes first depends on how the fan was
      presented.  Reading it backwards gives the chain of the inverse type, so a comparison with
      @TO hirzebruchJung@ should allow for a reversal unless the presentation is fixed.
  SeeAlso
    contractMinusOneCurves
///

doc ///
  Key
    contractMinusOneCurves
    (contractMinusOneCurves, List)
  Headline
    contract the curves of self-intersection minus one in a chain
  Usage
    contractMinusOneCurves bs
  Inputs
    bs:List
  Outputs
    :List
  Description
    Text
      Removes an entry equal to one and decreases its neighbours by one, repeatedly, until no entry
      equals one.  Applied to the output of @TO resolutionChain@ this turns the resolution produced
      by @TO destackify@ into the minimal one.
    Example
      contractMinusOneCurves {3, 1, 3}
      hirzebruchJung(3, 2)
///

doc ///
  Key
    hirzebruchJung
    (hirzebruchJung, ZZ, ZZ)
  Headline
    the Hirzebruch-Jung continued fraction
  Usage
    hirzebruchJung(r, q)
  Inputs
    r:ZZ
    q:ZZ
  Outputs
    :List
  Description
    Text
      Returns the partial quotients of the continued fraction expansion of {\tt r/q} with all signs
      negative.  Their negatives are the self-intersection numbers of the minimal resolution of the
      cyclic quotient surface singularity of order {\tt r} and type {\tt q}, so this is an
      independent check on @TO destackify@.
    Example
      hirzebruchJung(5, 2)
      hirzebruchJung(7, 3)
  SeeAlso
    resolutionChain
///

TEST ///
  -- multiplicity is the gcd of the maximal minors of the primitive generators
  F = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
  assert( coneMultiplicity(F, {0,1}) == 3 )
  assert( coneMultiplicity(F, {0}) == 1 )
  assert( coneMultiplicity(F, {}) == 1 )
  G = stackyFan({{1,0},{0,1}}, {1,1}, {{0,1}});
  assert( coneMultiplicity(G, {0,1}) == 1 )
  assert( isSmoothStackyFan G )
///

TEST ///
  -- the parallelotope has as many lattice points as the multiplicity
  F = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
  assert( # parallelotopeLattice(F, {0,1}) == 3 )
///

TEST ///
  -- Hirzebruch-Jung expansions
  assert( hirzebruchJung(3,1) == {3} )
  assert( hirzebruchJung(3,2) == {2,2} )
  assert( hirzebruchJung(5,2) == {3,2} )
  assert( hirzebruchJung(7,3) == {3,2,2} )
///

TEST ///
  -- a pseudo-reflection gives a smooth coarse space and a label, not a singularity
  G = basicToricStackyFan(2, {1,0});
  assert( coneMultiplicity(G, {0,1}) == 1 )
  assert( max stackyLabels G == 2 )
  H = basicToricStackyFan(2, {1,1});
  assert( coneMultiplicity(H, {0,1}) == 2 )
///

TEST ///
  -- the root construction does not change multiplicities
  F = stackyFan({{0,1},{5,-2}}, {1,1}, {{0,1}});
  m = coneMultiplicity(F, {0,1});
  rootConstruction(F, {0,1}, {3,4});
  assert( stackyLabels F == {3,4} )
  assert( coneMultiplicity(F, {0,1}) == m )
///

TEST ///
  -- destackify reproduces the Hirzebruch-Jung chain on cyclic quotient surface singularities
  for r from 2 to 6 do for q from 1 to r-1 do (
      if gcd(r,q) != 1 then continue;
      F := stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}});
      destackify F;
      assert isSmoothStackyFan F;
      assert( contractMinusOneCurves resolutionChain F == hirzebruchJung(r,q) );
      )
///

TEST ///
  -- the basis chosen by basicToricStackyFan presents the inverse type, so the chain is reversed
  for r from 2 to 6 do for q from 1 to r-1 do (
      if gcd(r,q) != 1 then continue;
      G := basicToricStackyFan(r, {1,q});
      destackify G;
      assert isSmoothStackyFan G;
      assert( contractMinusOneCurves resolutionChain G == reverse hirzebruchJung(r,q) );
      )
///

TEST ///
  -- the constructor and the two modifications reject input that would break the invariants the
  -- rest of the package relies on
  assert( (try stackyFan({{1,0},{0,1}}, {1,1}, {{0,5}}) else "err") === "err" )   -- index out of range
  assert( (try stackyFan({{1,0},{0,1}}, {1,1}, {{0,0}}) else "err") === "err" )   -- repeated ray
  assert( (try stackyFan({{1,0},{0,1}}, {1,1}, {{}})    else "err") === "err" )   -- empty cone
  assert( (try stackyFan({{1,0},{0,1}}, {1,0}, {{0,1}}) else "err") === "err" )   -- label not positive
  F = stackyFan({{1,0},{0,1}}, {1,1}, {{0,1}});
  assert( (try rootConstruction(F, {0}, {0})  else "err") === "err" )             -- weight not positive
  assert( (try rootConstruction(F, {0,0}, {2,2}) else "err") === "err" )          -- ray twice
  assert( stackyLabels F == {1,1} )
  -- a cone that is not a face of any maximal cone would add a ray no cone contains
  G = stackyFan({{1,0,0},{0,1,0},{0,0,1}}, {1,1,1}, {{0,1}});
  assert( (try starSubdivision(G, {0,2}) else "err") === "err" )
  assert( #(stackyRays G) == 3 )
///

TEST ///
  -- rank three: a simplicial cone of multiplicity three is resolved, and the resolution keeps
  -- the standard basis rays it started with
  F = stackyFan({{1,0,0},{0,1,0},{1,1,3}}, {1,1,1}, {{0,1,2}});
  assert( coneMultiplicity(F, {0,1,2}) == 3 )
  destackify F;
  assert isSmoothStackyFan F
  assert( take(stackyRays F, 3) == {{1,0,0},{0,1,0},{1,1,3}} )
  assert all(maximalCones F, c -> #c == 3)
///

TEST ///
  -- Algorithm A on its own: it makes the distinguished rays independent, but is not asked to
  -- make every cone smooth, so a cone with no distinguished ray is left alone
  F = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
  partialDestackify F;
  assert( coneMultiplicity(F, {0,1}) == 3 )
  assert( distinguishedRays F == {} )
  G = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
  partialDestackify(G, {0});
  assert( distinguishedRays G != {} )
  assert all(maximalCones G, c -> all(select(c, i -> member(i, distinguishedRays G)),
          rho -> isIndependentRay(G, c, rho)))
///

TEST ///
  -- Bergh's Example 4.1: the basic toric orbifold on which naive stacky star subdivision never
  -- improves.  Algorithm B still terminates.
  F = basicToricStackyFan(5, {1,3});
  assert( coneMultiplicity(F, {0,1}) == 5 )
  destackify F;
  assert isSmoothStackyFan F
  assert( contractMinusOneCurves resolutionChain F == hirzebruchJung(5,2) )
  assert( hirzebruchJung(5,2) == reverse hirzebruchJung(5,3) )
///
