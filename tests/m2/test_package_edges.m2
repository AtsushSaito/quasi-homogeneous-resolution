-- Edge cases, degenerate inputs, error handling and determinism for the package
-- ToricDestackification.  Every check is an assert; a failure stops the script with a non-zero status.
--   M2 --script tests/m2/test_package_edges.m2        (about 20 s)
path = prepend(currentFileDirectory | "../../package/", path);
needsPackage "ToricDestackification";
fails = thunk -> (try (thunk(); false) else true);
count = 0;
ok = (label, cond) -> (count = count + 1; if not cond then (<< "FAILED: " << label << endl; exit 1));

-- ---------------------------------------------------------------- Hirzebruch-Jung expansion
-- round trip: [b1,...,bk] evaluated as b1 - 1/(b2 - 1/(...)) returns r/q; all b_i >= 2
evalHJ = bs -> (x := promote(last bs, QQ); for b in reverse drop(bs, -1) do x = b - 1/x; x);
for r from 2 to 40 do for q from 1 to r - 1 do if gcd(r, q) == 1 then (
    bs := hirzebruchJung(r, q);
    ok("HJ round trip " | toString(r,q), evalHJ bs == r/q);
    ok("HJ entries >= 2 " | toString(r,q), all(bs, b -> b >= 2)));
ok("HJ(r,r-1) is a chain of r-1 twos", all(2..12, r -> hirzebruchJung(r, r-1) == toList((r-1) : 2)));
ok("HJ(r,1) = {r}", all(2..12, r -> hirzebruchJung(r, 1) == {r}));
ok("HJ(r, q) and HJ(r, q') are reverses when q q' = 1 mod r",
   all(2..30, r -> all(1..r-1, q -> gcd(r,q) != 1 or (
       qq := (select(1..r-1, t -> (q*t) % r == 1))#0;
       hirzebruchJung(r, qq) == reverse hirzebruchJung(r, q)))));
ok("HJ(5,0) is empty", hirzebruchJung(5, 0) == {});
ok("HJ rejects r = 0", fails(() -> hirzebruchJung(0, 1)));
ok("HJ rejects q < 0", fails(() -> hirzebruchJung(5, -1)));

-- ---------------------------------------------------------------- contractMinusOneCurves
ok("contract {}", contractMinusOneCurves {} == {});
ok("contract {2,2,2} unchanged", contractMinusOneCurves {2,2,2} == {2,2,2});
ok("contract {1} = {}", contractMinusOneCurves {1} == {});
ok("contract {3,1,2} -> {2,1} -> {1} -> {}", contractMinusOneCurves {3,1,2} == {});
ok("contract {2,1,3}", contractMinusOneCurves {2,1,3} == {});
ok("contract {1,3}", contractMinusOneCurves {1,3} == {2});
ok("contract {3,1,3}", contractMinusOneCurves {3,1,3} == {2,2});
L = {4,1,2,5};
M = contractMinusOneCurves L;
ok("contract does not mutate its argument", L == {4,1,2,5});
ok("contract {4,1,2,5} -> {3,1,5} -> {2,4}", M == {2,4});

-- ---------------------------------------------------------------- constructor validation
ok("no rays", fails(() -> stackyFan({}, {}, {})));
ok("ragged rays", fails(() -> stackyFan({{1,0},{0,1,0}}, {1,1}, {{0,1}})));
ok("label count", fails(() -> stackyFan({{1,0},{0,1}}, {1}, {{0,1}})));
ok("label zero", fails(() -> stackyFan({{1,0},{0,1}}, {1,0}, {{0,1}})));
ok("label negative", fails(() -> stackyFan({{1,0},{0,1}}, {1,-2}, {{0,1}})));
ok("label not an integer", fails(() -> stackyFan({{1,0},{0,1}}, {1,1/2}, {{0,1}})));
ok("cone index out of range", fails(() -> stackyFan({{1,0},{0,1}}, {1,1}, {{0,2}})));
ok("cone index negative", fails(() -> stackyFan({{1,0},{0,1}}, {1,1}, {{-1,1}})));
ok("cone repeats a ray", fails(() -> stackyFan({{1,0},{0,1}}, {1,1}, {{1,1}})));
ok("empty cone", fails(() -> stackyFan({{1,0},{0,1}}, {1,1}, {{}})));
ok("cone is not a list", fails(() -> stackyFan({{1,0},{0,1}}, {1,1}, {3})));

-- ---------------------------------------------------------------- multiplicity and lattice points
F = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
ok("multiplicity of a face", coneMultiplicity(F, {1}) == 1);
ok("multiplicity is symmetric in the order of the cone", coneMultiplicity(F, {1,0}) == coneMultiplicity(F, {0,1}));
D = stackyFan({{1,0},{2,0}}, {1,1}, {{0,1}});
ok("dependent rays: multiplicity refused", fails(() -> coneMultiplicity(D, {0,1})));
ok("dependent rays: parallelotope refused", fails(() -> parallelotopeLattice(D, {0,1})));
ok("parallelotope of the empty cone", parallelotopeLattice(F, {}) == {{}});
-- number of lattice points of the half-open parallelotope = multiplicity
for r from 1 to 9 do for q from 1 to r do if gcd(r,q) == 1 then (
    G := stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}});
    ok("parallelotope size " | toString(r,q), #parallelotopeLattice(G, {0,1}) == coneMultiplicity(G, {0,1})));
ok("a unimodular cone has only the origin", parallelotopeLattice(stackyFan({{1,0,0},{0,1,0},{0,0,1}}, {1,1,1}, {{0,1,2}}), {0,1,2}) == {{0,0,0}});
ok("isIndependentRay in a smooth cone",
   isIndependentRay(stackyFan({{1,0},{0,1}}, {1,1}, {{0,1}}), {0,1}, 0));
ok("isIndependentRay fails when the multiplicity drops", not isIndependentRay(F, {0,1}, 0));

-- ---------------------------------------------------------------- star subdivision and root construction
G = stackyFan({{1,0},{0,1}}, {1,1}, {{0,1}});
ok("starSubdivision: empty cone refused", fails(() -> starSubdivision(G, {})));
ok("starSubdivision: out of range", fails(() -> starSubdivision(G, {0,7})));
ok("starSubdivision: repeated ray", fails(() -> starSubdivision(G, {0,0})));
i = starSubdivision(G, {0,1});
ok("star subdivision of the orthant adds (1,1)", stackyRays G == {{1,0},{0,1},{1,1}} and i == 2);
ok("star subdivision gives two cones", sort maximalCones G == {{0,2},{1,2}});
ok("star subdivision of a smooth cone gives smooth cones", isSmoothStackyFan G);
H = stackyFan({{1,0},{0,1}}, {2,3}, {{0,1}});
j = starSubdivision(H, {0,1});     -- the new ray is generated by 2*e1 + 3*e2 and carries label gcd = 1
ok("new ray from labelled rays", last stackyRays H == {2,3} and last stackyLabels H == 1);
K = stackyFan({{1,0},{0,1}}, {2,2}, {{0,1}});
starSubdivision(K, {0,1});
ok("new ray is primitive, label = gcd", last stackyRays K == {1,1} and last stackyLabels K == 2);
ok("rootConstruction: length mismatch", fails(() -> rootConstruction(G, {0,1}, {2})));
ok("rootConstruction: index out of range", fails(() -> rootConstruction(G, {9}, {2})));
ok("rootConstruction: weight 0", fails(() -> rootConstruction(G, {0}, {0})));
ok("rootConstruction: negative weight", fails(() -> rootConstruction(G, {0}, {-1})));
L0 = stackyLabels G;
rootConstruction(G, {0}, {6});
ok("rootConstruction multiplies the label", (stackyLabels G)#0 == 6 * L0#0);
rootConstruction(G, {0}, {2});
ok("root constructions compose", (stackyLabels G)#0 == 12 * L0#0);

-- ---------------------------------------------------------------- Algorithm B on degenerate inputs
S1 = stackyFan({{1,0},{0,1}}, {1,1}, {{0,1}});
before = (stackyRays S1, stackyLabels S1, sort maximalCones S1);
destackify S1;
ok("a smooth fan is a fixed point of destackify", before == (stackyRays S1, stackyLabels S1, sort maximalCones S1));
S2 = stackyFan({{1}}, {1}, {{0}});
destackify S2;
ok("rank one smooth cone", isSmoothStackyFan S2 and stackyRays S2 == {{1}});
S3 = stackyFan({{1,0},{0,1}}, {5,7}, {{0,1}});     -- labels only: coarse space already smooth
destackify S3;
ok("labels alone do not trigger a modification", stackyRays S3 == {{1,0},{0,1}});
-- idempotence
T = stackyFan({{0,1},{7,-3}}, {1,1}, {{0,1}});
destackify T;
snap = (stackyRays T, stackyLabels T, sort maximalCones T);
destackify T;
ok("destackify is idempotent", snap == (stackyRays T, stackyLabels T, sort maximalCones T));
ok("destackify returns its argument", (T2 := stackyFan({{0,1},{7,-3}}, {1,1}, {{0,1}}); destackify T2 === T2));
-- iteration limit is enforced
U = stackyFan({{0,1},{9,-2}}, {1,1}, {{0,1}});
ok("MaxIterations is respected", fails(() -> destackify(U, MaxIterations => 1)));

-- ---------------------------------------------------------------- rank-2 structure of the output
for r from 2 to 10 do for q from 1 to r - 1 do if gcd(r,q) == 1 then (
    X := stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}});
    destackify X;
    ok("smooth " | toString(r,q), isSmoothStackyFan X);
    -- adjacent rays of the path form a basis, the two original rays are the ends of the path
    bs := resolutionChain X;
    ok("chain entries are integers >= 1 " | toString(r,q), all(bs, b -> instance(b, ZZ) and b >= 1));
    ok("contracted chain has entries >= 2 " | toString(r,q), all(contractMinusOneCurves bs, b -> b >= 2));
    ok("contracted chain = HJ " | toString(r,q), contractMinusOneCurves bs == hirzebruchJung(r, q));
    ok("every maximal cone is unimodular " | toString(r,q), all(maximalCones X, c -> abs det matrix(stackyRays X)_c == 1));
    ok("the original rays are still rays " | toString(r,q), take(stackyRays X, 2) == {{0,1},{r,-q}}));
ok("resolutionChain refuses rank 3", fails(() -> resolutionChain stackyFan({{1,0,0},{0,1,0},{0,0,1}}, {1,1,1}, {{0,1,2}})));
ok("basicToricStackyFan: order 0", fails(() -> basicToricStackyFan(0, {1,1})));
ok("basicToricStackyFan: negative order", fails(() -> basicToricStackyFan(-3, {1,1})));

-- ---------------------------------------------------------------- Algorithm A
Y1 = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
ok("partialDestackify: distinguished index out of range", fails(() -> partialDestackify(Y1, {5})));
Y2 = stackyFan({{1,0},{1,3}}, {1,1}, {{0,1}});
partialDestackify(Y2, {0,1});
ok("Algorithm A makes the distinguished rays independent",
   all(maximalCones Y2, c -> all(select(c, i -> member(i, distinguishedRays Y2)), rho -> isIndependentRay(Y2, c, rho))));

-- ---------------------------------------------------------------- determinism
run1 = (A1 := stackyFan({{1,0,0},{0,1,0},{1,1,4}}, {1,1,1}, {{0,1,2}}); destackify A1; (stackyRays A1, stackyLabels A1, maximalCones A1));
setRandomSeed 12345;
run2 = (A2 := stackyFan({{1,0,0},{0,1,0},{1,1,4}}, {1,1,1}, {{0,1,2}}); destackify A2; (stackyRays A2, stackyLabels A2, maximalCones A2));
setRandomSeed 2;
random(ZZ); random(ZZ);
run3 = (A3 := stackyFan({{1,0,0},{0,1,0},{1,1,4}}, {1,1,1}, {{0,1,2}}); destackify A3; (stackyRays A3, stackyLabels A3, maximalCones A3));
ok("output does not depend on the random seed", run1 == run2 and run2 == run3);
-- the constructor copies nothing it should not: two fans built from the same data are independent
P1 = stackyFan({{0,1},{5,-2}}, {1,1}, {{0,1}});
P2 = stackyFan({{0,1},{5,-2}}, {1,1}, {{0,1}});
destackify P1;
ok("fans built from the same data are independent", stackyRays P2 == {{0,1},{5,-2}} and coneMultiplicity(P2, {0,1}) == 5);

<< "package edge tests: " << count << " checks passed" << endl;
