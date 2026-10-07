-- StackyFan.m2 ---------------------------------------------------------------------------------
-- Bergh's toric destackification, implemented from
--   D. Bergh, "Functorial destackification of tame stacks with abelian stabilisers",
--   Compositio Math. 153 (2017) 1257-1315 = arXiv:1409.5713,
-- Definitions 2.6, 3.2, 3.5, 3.6, 3.8 and Algorithms A (A0-A6, p.14) and B (B0-B4, p.16),
-- with the four open choices of step A2 exposed as switches.
--
-- The lattice N is free of rank n.  A stacky fan (Def 3.2) is then faithfully recorded by
--   rays   : the primitive generator u_rho of each ray, in a fixed order (the order is part of
--            the data; Bergh p.14 "we will assume that the rays of the stacky fan are ordered")
--   labels : positive integers l_rho, so that beta(rho) = l_rho * u_rho
--   maxCones, dist (Def 2.6, distinguished rays)
--
-- Nothing in this file mentions a field, a polynomial or a characteristic: it is a pure
-- integer program (cf. Bergh 3.5: "the stacky structure beta
-- plays no part in the definition of multiplicity").

-- ---------------------------------------------------------------- small helpers

gcdL = L -> if #L == 0 then 0 else fold(L, gcd);
lcmL = L -> if #L == 0 then 1 else fold(L, lcm);
vplus = (a, b) -> apply(a, b, plus);
vscale = (c, a) -> apply(a, x -> c*x);
cartesian = L -> (
    if #L == 0 then return {{}};
    rest := cartesian drop(L, 1);
    flatten apply(L#0, a -> apply(rest, t -> prepend(a, t))));
lexLess = (a, b) -> (
    for i from 0 to #a - 1 do (
        if a#i < b#i then return true;
        if a#i > b#i then return false);
    false);

-- Bergh A2 says "the smallest element of P with respect to the lexicographic ordering" but does
-- not fix which end of the ordered ray list is most significant.  New rays are appended, so the
-- two readings differ: LexFirst prefers formal sums avoiding early (original) rays, LexLast
-- prefers sums avoiding late (newly created) rays.  Switchable so we can test both.
-- Ambiguities in Bergh A2, made switchable so they can be swept (the A2 ordering sweep (scripts/sweep_a2.sh)):
--   psiOrder   : which end of the ordered ray list is most significant in the lex choice of psi
--   a2Extreme  : "maximal with respect to this ordering" -- max or min
--   a2Key      : (number of non-distinguished rays, multiplicity) or the reverse priority
--   a2Interior : lattice points in the relative interior of P_sigma, or anywhere in P_sigma
psiOrder = "last";
a2Extreme = "max";
a2Key = "nd-mult";
a2Interior = true;
psiLess = (a, b) -> if psiOrder == "first" then lexLess(a, b) else lexLess(reverse a, reverse b);

-- ---------------------------------------------------------------- the type

StackyFan = new Type of MutableHashTable;

stackyFan = method();
stackyFan (List, List, List) := (rys, lbls, cns) -> new StackyFan from {
    "rays" => rys, "labels" => lbls, "maxCones" => unique apply(cns, c -> sort c),
    "dist" => {}, "log" => {}, "multCache" => new MutableHashTable};

copySF = F -> new StackyFan from {
    "rays" => F#"rays", "labels" => F#"labels", "maxCones" => F#"maxCones",
    "dist" => F#"dist", "log" => F#"log", "multCache" => new MutableHashTable};

net StackyFan := F -> net("StackyFan(" | toString(#F#"rays") | " rays, " |
    toString(#F#"maxCones") | " maximal cones, labels " | toString(F#"labels") | ")");

-- every subset of a simplicial cone is a cone
allConesSF = F -> unique flatten apply(F#"maxCones", c -> subsets c);

-- ---------------------------------------------------------------- Def 3.5: multiplicity
-- mult(sigma) = number of lattice points of P_sigma = gcd of the r x r minors of the matrix of
-- PRIMITIVE generators.  The labels (i.e. beta) are deliberately not used.

multSF = (F, sigma) -> (
    if #sigma == 0 then return 1;
    key := sort sigma;
    cache := F#"multCache";
    if cache#?key then return cache#key;             -- rays never change, so this is stable
    U := matrix apply(key, i -> F#"rays"#i);
    -- A cone whose rays are dependent has an empty maximal-minors ideal, and the multiplicity
    -- would come out 0.  Both A1 and B1 filter on mult > 1, so such a cone is skipped and the
    -- loop reports "done" on a fan that is not smooth.  Refuse instead.
    if rank U != #key then error("multSF: the rays of cone " | toString key | " are linearly dependent");
    m := abs gcdL flatten entries gens minors(#key, U);
    cache#key = m;
    m);

-- lattice points of the half-open parallelotope P_sigma, as coefficient vectors lambda in [0,1)^r.
-- lambda*U in ZZ^n  <=>  nu := lambda*P^{-1} satisfies nu_i*d_i in ZZ, where D = P*U*Q (Smith).
parallelotopeSF = (F, sigma) -> (
    r := #sigma;
    if r == 0 then return {{}};
    U := matrix apply(sigma, i -> F#"rays"#i);
    (D, P, Q) := smithNormalForm(U, ChangeMatrix => {true, true});
    ds := apply(r, i -> D_(i,i));
    if any(ds, d -> d == 0) then error "parallelotopeSF: cone is not simplicial";
    Pq := promote(P, QQ);
    unique apply(cartesian apply(ds, d -> toList(0 .. d-1)), tup -> (
        nu := matrix {apply(r, i -> (tup#i) / (ds#i))};
        apply(flatten entries (nu * Pq), x -> x - floor x))));

interiorPointsSF = (F, sigma) -> select(parallelotopeSF(F, sigma), lam -> all(lam, x -> x > 0));

-- ---------------------------------------------------------------- Def 3.8: independency
isIndepSF = (F, sigma, rho) -> multSF(F, select(sigma, i -> i != rho)) == multSF(F, sigma);

-- ---------------------------------------------------------------- Def 3.5: star subdivision
-- The new ray is generated by v = sum over rho in sigma(1) of beta(rho), and beta(rho_0) := v.
starSubdivSF = (F, sigma) -> (
    n := #(F#"rays"#0);
    v := fold(apply(sigma, i -> vscale(F#"labels"#i, F#"rays"#i)), vplus);
    g := gcdL v;
    u := apply(v, x -> x // g);
    ni := position(F#"rays", x -> x == u);
    if ni === null then (
        F#"rays" = append(F#"rays", u);
        F#"labels" = append(F#"labels", g);
        ni = #F#"rays" - 1)
    else if F#"labels"#ni != g then
        error("starSubdivSF: ray " | toString u | " already present with label " |
              toString F#"labels"#ni | ", new beta wants " | toString g);
    newMax := {};
    for c in F#"maxCones" do
        if isSubset(sigma, c) then
            for rho in sigma do newMax = append(newMax, sort append(select(c, i -> i != rho), ni))
        else newMax = append(newMax, c);
    F#"maxCones" = unique newMax;
    F#"log" = append(F#"log", ("star", sigma, u, g));
    ni);

-- ---------------------------------------------------------------- Def 3.6: root construction
-- beta'(rho) = d(rho)*beta(rho) for rho in the given set; the multiplicities are unchanged.
rootSF = (F, rhos, ds) -> (
    lb := new MutableList from F#"labels";
    for k from 0 to #rhos - 1 do lb#(rhos#k) = lb#(rhos#k) * (ds#k);
    F#"labels" = toList lb;
    F#"log" = append(F#"log", ("root", rhos, ds));
    F);

-- ---------------------------------------------------------------- psi: formal sums of rays
psiVec = (psi, nr) -> apply(nr, i -> if psi#?i then psi#i else 0);
psiBeta = (F, psi) -> fold(apply(sort keys psi, i -> vscale(psi#i * F#"labels"#i, F#"rays"#i)), vplus);

-- ---------------------------------------------------------------- Algorithm A (A0-A6)

algorithmA = method(Options => {MaxIter => 5000, Verbose => false});
algorithmA StackyFan := opts -> F -> (
    iter := 0;
    while true do (
        iter = iter + 1;
        if iter > opts.MaxIter then error "algorithmA: iteration limit exceeded";
        -- A1 [Check if finished]
        S := select(allConesSF F, sigma -> #sigma > 0
                and any(sigma, i -> member(i, F#"dist"))
                and multSF(F, sigma) > 1                     -- mult 1 => P_sigma = {0}
                and #(interiorPointsSF(F, sigma)) > 0);
        if #S == 0 then break;
        -- A2 [Choose a formal sum of rays]
        keyOf := sigma -> (
            nd := #select(sigma, i -> not member(i, F#"dist"));
            m := multSF(F, sigma);
            if a2Key == "nd-mult" then {nd, m} else {m, nd});
        keys2 := apply(S, keyOf);
        best := keys2#0;
        for k in keys2 do if (if a2Extreme == "max" then lexLess(best, k) else lexLess(k, best)) then best = k;
        Smax := select(S, sigma -> keyOf sigma == best);
        cands := {};
        for sigma in Smax do for lam in (if a2Interior then interiorPointsSF(F, sigma)
                                         else select(parallelotopeSF(F, sigma), l -> any(l, x -> x > 0))) do (
            m := lcmL apply(lam, x -> denominator x);
            as := apply(lam, x -> lift(x * m, ZZ));
            ls := apply(sigma, i -> F#"labels"#i);
            s := lcmL apply(select(toList(0..#sigma-1), j -> as#j > 0), j -> (ls#j) // gcd(as#j, ls#j));
            cs := apply(#sigma, j -> s * (as#j) // (ls#j));
            cands = append(cands, new HashTable from select(apply(#sigma, j -> sigma#j => cs#j), pr -> pr#1 > 0)));
        nr := #F#"rays";
        vecs := apply(cands, p -> psiVec(p, nr));
        bi := 0;
        for j from 1 to #vecs - 1 do if psiLess(vecs#j, vecs#bi) then bi = j;
        psi := cands#bi;
        b0 := psiBeta(F, psi);
        if opts.Verbose then << "  A2: psi = " << pairs psi << ",  beta(psi) = " << b0 << endl;
        -- A3 [Root distinguished rays]
        supp := sort keys psi;
        distIn := select(supp, i -> member(i, F#"dist"));
        if #distIn > 0 then (
            rootSF(F, distIn, apply(distIn, i -> psi#i));
            psi = new HashTable from (
                apply(select(supp, i -> not member(i, F#"dist")), i -> i => psi#i) |
                apply(distIn, i -> i => 1));
            if psiBeta(F, psi) != b0 then error "algorithmA: A3 broke the transformation rule");
        -- A4/A5 [Stacky star subdivisions until the support is a single ray]
        while #(keys psi) > 1 do (
            sig := sort keys psi;
            eps := starSubdivSF(F, sig);
            F#"dist" = unique append(F#"dist", eps);
            newpsi := select(apply(sig, i -> i => psi#i - 1), pr -> pr#1 > 0);
            psi = new HashTable from append(newpsi, eps => 1);
            if psiBeta(F, psi) != b0 then error "algorithmA: A4 broke the transformation rule";
            if opts.Verbose then << "  A4: subdivided " << sig << " -> psi = " << pairs psi << endl);
        );
    F);

-- ---------------------------------------------------------------- Algorithm B (B0-B4)

algorithmB = method(Options => {MaxIter => 5000, Verbose => false});
algorithmB StackyFan := opts -> F -> (
    iter := 0;
    while true do (
        iter = iter + 1;
        if iter > opts.MaxIter then error "algorithmB: iteration limit exceeded";
        -- B1 [Choose a cone]: no ray of sigma(1) is independent at sigma
        S := select(allConesSF F, sigma -> #sigma > 0
                and multSF(F, sigma) > 1                     -- mult 1 => all rays independent
                and not any(sigma, rho -> isIndepSF(F, sigma, rho)));
        if #S == 0 then break;
        dmax := max apply(S, s -> #s);
        sigma := last sort select(S, s -> #s == dmax);
        if opts.Verbose then << "B1: sigma = " << sigma << " (mult " << multSF(F, sigma) << ")" << endl;
        -- B2 [Create distinguished ray]
        eps := starSubdivSF(F, sigma);
        -- B3 [Resolve the cone]
        F#"dist" = {eps};
        algorithmA(F, MaxIter => opts.MaxIter, Verbose => opts.Verbose);
        -- B4 [Iterate]
        F#"dist" = {});
    F);

isSmoothSF = F -> all(F#"maxCones", c -> multSF(F, c) == 1);
isDestackified = F -> isSmoothSF F;   -- Bergh Thm 1.2: the COARSE space becomes smooth;
                                      -- labels > 1 may remain and encode the root stack.

-- ---------------------------------------------------------------- basic toric stacks [A^m/mu_r]
-- N = ZZ^m + ZZ*(1/r)*a  inside QQ^m, sigma = the positive orthant, beta(rho_i) = e_i.
-- Returned in coordinates of a ZZ-basis of N.
basicToricStackyFan = (r, a) -> (
    m := #a;
    M := matrix(apply(m, i -> apply(m, j -> if i == j then r else 0)) | {toList a});
    (D, P, Q) := smithNormalForm(M, ChangeMatrix => {true, true});
    ds := apply(m, i -> D_(i,i));
    B := (diagonalMatrix ds) * inverse promote(Q, QQ);      -- basis of r*N, rows
    Binv := inverse B;
    rys := {}; lbls := {};
    for i from 0 to m - 1 do (
        x := flatten entries ((matrix {apply(m, j -> if j == i then r else 0)}) * Binv);
        if any(x, t -> denominator t != 1) then error "basicToricStackyFan: non-integral coordinate";
        xz := apply(x, t -> lift(t, ZZ));
        g := gcdL xz;
        rys = append(rys, apply(xz, t -> t // g));
        lbls = append(lbls, g));
    stackyFan(rys, lbls, {toList(0 .. m-1)}));

-- ---------------------------------------------------------------- surfaces: read off the chain
-- In a smooth 2-dimensional fan the rays form a path; for an interior ray v_j with neighbours
-- v_{j-1}, v_{j+1} one has v_{j-1} + v_{j+1} = b_j v_j and the self-intersection is -b_j.
chainSF = F -> (
    if #(F#"rays"#0) != 2 then error "chainSF: only for rank 2";
    adj := new MutableHashTable;
    for i from 0 to #F#"rays" - 1 do adj#i = {};
    for c in F#"maxCones" do (
        if #c != 2 then continue;
        adj#(c#0) = append(adj#(c#0), c#1);
        adj#(c#1) = append(adj#(c#1), c#0));
    used := select(keys adj, i -> #(adj#i) > 0);
    ends := select(used, i -> #(adj#i) == 1);
    if #ends != 2 then error("chainSF: not a path (" | toString(#ends) | " endpoints)");
    ends = sort ends;   -- keys of a MutableHashTable have no specified order
    path := {first ends}; prev := -1; cur := first ends;
    while true do (
        nx := select(adj#cur, j -> j != prev);
        if #nx == 0 then break;
        prev = cur; cur = first nx; path = append(path, cur));
    -- Two endpoints is not enough: a path plus a disjoint cycle also has exactly two, and the
    -- traversal would return the path alone as if it were the whole chain.
    if #path != #used then error("chainSF: the fan is not connected (" | toString(#path)
        | " of " | toString(#used) | " rays reached)");
    interior := take(path, {1, #path - 2});
    bs := apply(#interior, k -> (
        vm := F#"rays"#(path#k); v := F#"rays"#(path#(k+1)); vp := F#"rays"#(path#(k+2));
        s := vplus(vm, vp);
        idx := position(v, t -> t != 0);
        if s#idx % v#idx != 0 then error "chainSF: non-integral self-intersection";
        b := s#idx // v#idx;
        if vplus(s, vscale(-b, v)) != {0, 0} then error "chainSF: v_{j-1}+v_{j+1} is not a multiple of v_j";
        b));
    (path, interior, bs));

-- Hirzebruch-Jung continued fraction r/q = [b_1, ..., b_k]  (independent oracle)
hjChainSF = (r, q) -> (
    L := {}; rr := r; qq := q;
    while qq > 0 do (b := ceiling(rr / qq); L = append(L, b); (rr, qq) = (qq, b*qq - rr));
    L);

-- Bergh's algorithm produces a resolution, not the MINIMAL one (the paper optimises for
-- functoriality, not for economy).  Contracting (-1)-curves in the chain recovers the minimal
-- resolution, which is what the Hirzebruch-Jung continued fraction predicts.
minimalizeChain = bs -> (
    L := bs;
    while true do (
        j := position(L, b -> b == 1);
        if j === null then break;
        if j > 0 then L = replace(j-1, L#(j-1) - 1, L);
        if j < #L - 1 then L = replace(j+1, L#(j+1) - 1, L);
        L = drop(L, {j, j}));
    L);

-- normalise 1/r(a,b) to 1/r'(1,q) by removing pseudo-reflections (r' = 1 means smooth)
cyclicType = (r, a, b) -> (
    rr := r; aa := a % r; bb := b % r;
    if rr == 1 then return (1, 0);
    changed := true;
    while changed do (
        changed = false;
        g := gcd(rr, aa);
        if g > 1 then (rr = rr // g; aa = (aa // g) % rr; bb = bb % rr; changed = true);
        if rr == 1 then return (1, 0);
        g = gcd(rr, bb);
        if g > 1 then (rr = rr // g; bb = (bb // g) % rr; aa = aa % rr; changed = true);
        if rr == 1 then return (1, 0));
    ainv := 1; for t from 1 to rr - 1 do if (aa * t) % rr == 1 then ainv = t;
    (rr, (bb * ainv) % rr));
