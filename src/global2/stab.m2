-- stab.m2 -- global2, units S2 and S3: stabiliser loci and local eigencoordinates on the charts of charts.m2.
-- (load charts.m2 first.)
--
--   fixedLoci(C)                  the loci Z_r = {v = 0 : r does not divide deg v} of the chart C, for the r > 1
--                                 dividing N = w_i, which of them carry points of stabiliser exactly mu_r, and
--                                 the Jacobian test that each Z_r is smooth.
--   stabiliserPatterns(C)         the same data, enumerated by support patterns S of the nonzero coordinates
--                                 (H_S = intersection of the kernels of the characters of S).  Exponential in
--                                 the number of variables; used to cross-check fixedLoci on small charts.
--   chartPreference(K, w, r, p)   the order in which the charts i in K are tried for eigencoordinates.
--   eigenCoords(C, r, Pt)         a basis of m/m^2 at the point (or component) Pt of the stratum of C, made of
--                                 elements homogeneous for mu_r, and the multiset of their characters.
--   eigenCoordsForStratum         the same, starting from a stratum component of qhPredict: picks the chart.
--
-- Group-theoretic setup (chart i).  The group is mu_N, N = w_i, and the variable v has character deg v in Z/N.
-- A point whose nonzero coordinates form S has stabiliser H_S = {zeta in mu_N : zeta^(deg v) = 1 for v in S},
-- of order gcd(N, deg v : v in S) (S may be empty: the point x_i = 1, all other coordinates 0).  For r | N the subgroup mu_r fixes exactly the points with v = 0 whenever
-- r does not divide deg v; the scheme of these points is Z_r = V(I + (v : r does not divide deg v)).  The
-- coordinate s has degree -1, so Z_r lies in {s = 0} for r > 1 (the stabiliser is nontrivial only on E).

-- ------------------------------------------------------------------ smoothness by the Jacobian criterion
-- V(J) is smooth over k iff for every minimal prime P of J (of codimension c) the ideal
-- P + minors(c, jacobian J) is the unit ideal.  (Rank >= c at every point of P bounds the tangent space
-- by the dimension of the component, so the local ring is regular; this also excludes embedded points and
-- non-reduced components.)  The empty scheme is smooth.
idealIsSmooth = J0 -> (
    Rg := ring J0;
    if J0 == ideal 1_Rg then return true;
    J := trim J0;
    Jac := jacobian J;
    all(minimalPrimes J, P -> (
        c := codim P;
        P + minors(c, Jac) == ideal 1_Rg)))

divisorsOfInt = N -> select(toList(1..N), d -> N % d == 0)

-- ------------------------------------------------------------------ S2: fixed loci
-- returns a HashTable with
--   "Z"       HashTable  r -> ideal of Z_r        (only for r > 1, r | N, Z_r nonempty)
--   "exact"   HashTable  r -> ideal of the closure of {points of stabiliser exactly mu_r}  (only if nonempty)
--   "rSet"    sorted list of the r with "exact" nonempty
--   "smooth"  HashTable  r -> "SMOOTH" | "NOT-SMOOTH" | "ERROR"   (Jacobian test, F2) for each r in "Z"
fixedLoci = method()
fixedLoci (GradedChart) := C -> (
    Rc := C#"ring"; I := C#"I"; N := C#"N"; degs := C#"degs";
    one := ideal 1_Rc;
    rs := select(divisorsOfInt N, r -> r > 1);
    Z := new MutableHashTable;
    for r in rs do (
        -- m = 1: the degree of a variable is a single integer
        killed := select(toList(0..numgens Rc - 1), k -> (degs#k#0) % r != 0);
        Zr := I + ideal apply(killed, k -> Rc_k);
        if Zr != one then Z#r = Zr);
    exact := new MutableHashTable;
    for r in sort keys Z do (
        U := Z#r;
        for r2 in select(sort keys Z, a -> a > r and a % r == 0) do U = saturate(U, Z#r2);
        if U != one then exact#r = U);
    smooth := new MutableHashTable;
    for r in sort keys Z do
        smooth#r = (try (if idealIsSmooth(Z#r) then "SMOOTH" else "NOT-SMOOTH") else "ERROR");
    new HashTable from {"Z" => new HashTable from Z, "exact" => new HashTable from exact,
        "rSet" => sort keys exact, "smooth" => new HashTable from smooth})

-- the same by support patterns (small charts only)
stabiliserPatterns = method()
stabiliserPatterns (GradedChart) := C -> (
    Rc := C#"ring"; I := C#"I"; N := C#"N"; degs := C#"degs";
    nv := numgens Rc; one := ideal 1_Rc;
    out := {};
    for S in subsets(toList(0..nv-1)) do (
        r := gcd(append(apply(S, k -> degs#k#0), N));
        if r == 1 then continue;
        rest0 := select(toList(0..nv-1), k -> not member(k, S));
        IS := saturate(I + ideal apply(rest0, k -> Rc_k), product apply(S, k -> Rc_k));
        if IS == one then continue;
        out = append(out, new HashTable from {"S" => S, "r" => r, "ideal" => IS}));
    out)

-- ------------------------------------------------------------------ S3: eigencoordinates
-- Order in which the charts i in K (indices of the nonzero coordinates of a stratum of order r) are tried.
-- In the chart x_i = 1 the orbit of a point of the stratum is a mu_{w_i/r}-torsor over its residue field;
-- when p divides w_i/r it is non-reduced, and such charts are tried last.  Returns (order, flag) where
-- flag is true when every chart of K has p | w_i/r.
chartPreference = method()
chartPreference (List, List, ZZ, ZZ) := (K, w, r, p) -> (
    bad := i -> p > 0 and (w#i // r) % p == 0;
    good := select(sort K, i -> not bad i);
    worse := select(sort K, i -> bad i);
    (good | worse, #good == 0))

-- eigenCoords(C, r, Pt): C a chart, r the order of the stabiliser mu_r, Pt a radical ideal of the chart ring
-- defining a point (or a component) of the stratum, contained in Z_r.
-- C is assumed to be a hypersurface chart (I principal).  The cotangent space of V(I) at Pt is spanned by
-- the differentials of all the variables modulo d(g), g the generator of I.  A variable v0 with d_{v0} g not
-- in Pt can be eliminated, and then the remaining variables (shifted by their value at the point when the
-- variable has weight 0 and the point is rational) form a basis of m/m^2.  Every variable is an eigenvector
-- of mu_r with weight (deg v mod r); the shifted ones have weight 0.
-- Returns a HashTable: "verdict" ("EC-OK" or "EC-FLAG"), "flags" (list of strings), "tw" (sorted weights),
-- "v0" (position of the eliminated variable), "coords" (list of ring elements), "weights",
-- "rational" (are the weight-0 shifts known?), "r".
eigenCoords = method()
eigenCoords (GradedChart, ZZ, Ideal) := (C, r, Pt) -> (
    Rc := C#"ring"; nv := numgens Rc; degs := C#"degs"; flags := {};
    gI := flatten entries gens trim C#"I";
    if #gI != 1 then return new HashTable from {"verdict" => "EC-FLAG", "flags" => {"chart ideal is not principal"}, "r" => r};
    g := first gI;
    wt := apply(nv, k -> (degs#k#0) % r);
    partials := apply(nv, k -> diff(Rc_k, g));
    cand := select(toList(0..nv-1), k -> not isSubset(ideal partials#k, Pt));
    if #cand == 0 then
        return new HashTable from {"verdict" => "EC-FLAG", "flags" => {"CHART-SINGULAR-AT-POINT: all partials of the chart equation vanish"}, "r" => r};
    if #unique apply(cand, k -> wt#k) != 1 then
        flags = append(flags, "weights of d(g) disagree: " | toString apply(cand, k -> wt#k));
    v0 := first cand;
    others := select(toList(0..nv-1), k -> k != v0);
    -- the check that the chosen elements form a basis: the Jacobian row of g together with the unit rows e_k,
    -- k != v0, has determinant +- d_{v0} g, which is a unit at the point.
    Jm := matrix {partials} || matrix apply(others, k -> apply(nv, l -> if l == k then 1_Rc else 0_Rc));
    if det Jm % Pt == 0 then flags = append(flags, "basis check failed");
    rational := dim Pt == 0 and degree Pt == 1;
    coords := apply(others, k -> (
        if wt#k != 0 or not rational then Rc_k
        else (
            val := Rc_k % Pt;
            if liftable(val, coefficientRing Rc) then Rc_k - val else (rational = false; Rc_k))));
    if not rational and any(others, k -> wt#k == 0) then
        flags = append(flags, "weight-0 coordinates are not shifted: the stratum point is not rational (or not a closed point)");
    new HashTable from {"verdict" => (if #flags == 0 then "EC-OK" else "EC-FLAG"), "flags" => flags,
        "tw" => sort apply(others, k -> wt#k), "v0" => v0, "coords" => coords,
        "weights" => apply(others, k -> wt#k), "rational" => rational, "r" => r})

-- stratum component of qhPredict (HashTable with "K", "r", "P" an ideal of ring f): choose a chart from the
-- list `charts` of yCharts, map P to it, and compute eigencoordinates at every component of the image.
-- The result has "tw" (common to all components, else flag), "chart" (index i), "flags".
eigenCoordsForStratum = method()
eigenCoordsForStratum (List, HashTable) := (charts, pred) -> (
    K := pred#"K"; r := pred#"r"; P := pred#"P";
    p := char ring P;
    w := (first charts)#"w";
    (order, noGoodChart) := chartPreference(K, w, r, p);
    flags := if noGoodChart then {"NO-REDUCED-CHART: p divides w_i/r for every i in K"} else {};
    lastFlagged := null;
    for i in order do (
        C := charts#i; Rc := C#"ring";
        pts := minimalPrimes(radical ((C#"pullback") P + ideal last gens Rc));
        results := apply(pts, Pt -> eigenCoords(C, r, Pt));
        if all(results, e -> e#"verdict" == "EC-OK") and #unique apply(results, e -> e#"tw") == 1 then (
            fl := flags;
            if p > 0 and (w#i // r) % p == 0 then fl = append(fl, "chart " | toString i | " has p | w_i/r");
            if i != first order then fl = append(fl, "preferred chart " | toString first order | " was unusable");
            return new HashTable from {"verdict" => (if #fl == 0 then "EC-OK" else "EC-FLAG"), "flags" => fl,
                "tw" => (first results)#"tw", "chart" => i, "results" => results});
        lastFlagged = (i, results));
    new HashTable from {"verdict" => "EC-FLAG", "flags" => flags | {"no chart of K gives a clean eigenbasis"}, "tw" => null, "chart" => null})
