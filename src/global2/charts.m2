-- charts.m2 -- global2, unit S1: the atlas of Y = [((V(f) \ 0) x A^1_s) / G_m] by graded charts.
--
--   GradedChart              a polynomial ring k[v_1..v_N], a homogeneous ideal I, a degree group
--                            A = Z^m / L, a degree deg(v_j) in Z^m for each variable, and a list of divisors.
--   yCharts(f, w)            the n cone charts C_i (x_i != 0) of Y: k[x_0..x_{n-1}, s, x_i'] / (f, x_i x_i' - 1),
--                            A = Z, deg x_j = w_j, deg s = -1, deg x_i' = -w_i, divisor E = (s).
--   ySliceCharts(f, w)       the slice charts k[x_j (j != i), s]/(f|_{x_i=1}), A = Z/w_i; kept for comparison (p | w_i fails).
--   chartHomogeneous(C, g)   is the element g homogeneous for the grading of C?
--   chartContainsStratum     is a stratum of qhReport (K, ideal) a closed subset of the chart C_i?
--
-- Conventions (docs/M2_NOTES.md): chart variables are called yy (a name that cannot clash with x, y, z, s, t);
-- the variables of chart i are yy_j for j in {0..n-1} \ {i}, in increasing order, followed by yy_n = s.
-- Nothing here changes src/qh.m2, src/StackyFan.m2 or the package; only the data of qhReport is read.

GradedChart = new Type of HashTable
GradedChart.synonym = "graded chart"

-- keys of a GradedChart:
--   "ring"      the polynomial ring of the chart            "I"        the ideal (of the hypersurface)
--   "m", "L"    A = Z^m / (columns of L), L an m x k matrix over ZZ
--   "degs"      list of length numgens ring, each a list of m integers
--   "divisors"  list of (name, ring element) pairs: the local equations of the divisors
--   "i"         the index i of the chart (x_i = 1)           "n"        the number of x-variables of Y
--   "w"         the weights of Y                              "N"        w_i, the order of the group mu_N
--   "varIndex"  for each variable of the ring, its index in {0..n}  (n stands for s)
--   "pullback"  the ring map from ring f to the chart ring, x_i -> 1, x_j -> yy_j

-- is the element g of chart C homogeneous for A = Z^m / L ?  (the zero element is homogeneous)
chartHomogeneous = method()
chartHomogeneous (GradedChart, RingElement) := (C, g) -> (
    if g == 0 then return true;
    degs := C#"degs"; m := C#"m"; L := C#"L";
    D := matrix apply(m, a -> apply(#degs, j -> (degs#j)#a));       -- m x (number of variables)
    vecs := apply(exponents g, e -> D * transpose matrix{e});
    v0 := first vecs;
    all(vecs, v -> (
        delta := v - v0;
        if delta == 0 then true
        else if numColumns L == 0 or L == 0 then false
        else L * (delta // L) == delta)))

chartHomogeneousIdeal = method()
chartHomogeneousIdeal (GradedChart) := C -> all(flatten entries gens C#"I", g -> chartHomogeneous(C, g))

-- the slice atlas (NOT used by the pipeline since the cone decision).  Raises an error for input outside the hypotheses (non-positive weights, f not
-- quasi-homogeneous); use tryYCharts to get a verdict instead.
ySliceCharts = method()
ySliceCharts (RingElement, List) := (f, w) -> (
    R := ring f; n := numgens R; kk := coefficientRing R;
    if #w != n then error "ySliceCharts: the number of weights differs from the number of variables";
    if not all(w, a -> class a === ZZ and a > 0) then error "ySliceCharts: weights must be positive integers";
    if f == 0 then error "ySliceCharts: f = 0";
    lf := listForm f;
    degs0 := unique apply(lf, pr -> sum apply(n, j -> (pr#0)#j * w#j));
    if #degs0 != 1 then error("ySliceCharts: f is not quasi-homogeneous for w, degrees " | toString degs0);
    atlas := for i from 0 to n-1 list (
        varIdx := select(toList(0..n-1), j -> j != i) | {n};
        Rc := kk[apply(varIdx, j -> (getSymbol "yy")_j)];
        images := apply(n, j -> if j == i then 1_Rc else Rc_(position(varIdx, a -> a == j)));
        phi := map(Rc, R, images);
        g := phi f;
        sIdx := #varIdx - 1;
        C := new GradedChart from {
            "ring" => Rc, "I" => ideal g, "m" => 1, "L" => matrix{{w#i}},
            "degs" => apply(varIdx, j -> if j == n then {-1} else {w#j}),
            "divisors" => {("E", Rc_sIdx)},
            "i" => i, "n" => n, "w" => w, "N" => w#i, "varIndex" => varIdx, "pullback" => phi};
        assert(chartHomogeneousIdeal C);
        C);
    atlas)

-- verdict-returning wrapper: G2-ERROR with a message instead of an exception
tryYCharts = method()
tryYCharts (RingElement, List) := (f, w) -> (
    try new HashTable from {"verdict" => "G2-OK", "charts" => yCharts(f, w)}
    else new HashTable from {"verdict" => "G2-ERROR", "message" => "yCharts failed on this input"})

-- Does the chart C_i contain the stratum st (a HashTable of qhReport: "K", "ideal")?  The stratum of Y
-- is {x in V(ideal), s = 0}.  We test on ideals: the image of the ideal under x_i -> 1 (plus the
-- equation s of the divisor E) must be proper, i.e. the stratum meets x_i != 0, and must contain the
-- equation of the chart, so that it defines a closed subset of V(I) in the chart.
chartContainsStratum = method()
chartContainsStratum (GradedChart, HashTable) := (C, st) -> (
    Rc := C#"ring";
    sEq := (first select(C#"divisors", d -> d#0 == "E"))#1;
    img := (C#"pullback") st#"ideal" + ideal sEq;               -- + (s)
    -- cone chart: add x_i x_i' - 1 so that the stratum is cut out inside the chart; slice chart: x_i = 1 already
    J := if numgens Rc > C#"n" + 1 then img + ideal(Rc_(C#"i") * last gens Rc - 1_Rc) else img;
    J != ideal 1_Rc and isSubset(C#"I", J))

-- ------------------------------------------------------------------ the atlas yCharts: cone charts
-- Decision (user, 2026-10): the atlas of Y is the cone atlas.  The slice atlas ySliceCharts above is kept
-- only to document why: the slice x_i = 1 is an etale atlas of Y only when p does not divide w_i; for p | w_i
-- the slice can be a singular scheme although Y is smooth.  The cone chart uses the open set x_i != 0 of V(f) x A^1 itself, which is smooth in every
-- characteristic, with the grading group A = Z (L = 0) of G_m:
--   k[x_0..x_{n-1}, s, x_i'] / (f, x_i x_i' - 1),  deg x_j = w_j, deg s = -1, deg x_i' = -w_i.
-- Variables: yy_0..yy_{n-1} = x, yy_n = s, yy_{n+1} = x_i'.
yCharts = method()
yCharts (RingElement, List) := (f, w) -> (
    R := ring f; n := numgens R; kk := coefficientRing R;
    if #w != n or not all(w, a -> class a === ZZ and a > 0) then error "yCharts: bad weights";
    lf := listForm f;
    if #unique apply(lf, pr -> sum apply(n, j -> (pr#0)#j * w#j)) != 1 then error "yCharts: f is not quasi-homogeneous";
    for i from 0 to n-1 list (
        Rc := kk[apply(n + 2, j -> (getSymbol "yy")_j)];
        phi := map(Rc, R, apply(n, j -> Rc_j));
        C := new GradedChart from {
            "ring" => Rc, "I" => ideal(phi f, Rc_i * Rc_(n+1) - 1_Rc), "m" => 1, "L" => map(ZZ^1, ZZ^1, 0),
            "degs" => apply(n, j -> {w#j}) | {{-1}, {-(w#i)}},
            "divisors" => {("E", Rc_n)},
            "i" => i, "n" => n, "w" => w, "N" => w#i, "varIndex" => toList(0..n+1), "pullback" => phi};
        assert(chartHomogeneousIdeal C);
        C))
