-- Catalog runner for fans.tsv: Bergh's Algorithm B on simplicial cones of rank 2, 3 and 4.
-- The expected multiplicity before and the numbers of rays and maximal cones after are fixed in the
-- table.  Independently of the package, the runner also checks with exact integer arithmetic that
-- every maximal cone of the output is unimodular and that every ray lies in the original cone.
--   M2 --script tests/catalog/run_fans.m2            # tier ci
--   TIER=all M2 --script tests/catalog/run_fans.m2   # adds the heavy rows (minutes)
path = prepend(currentFileDirectory | "../../package/", path);
needsPackage "ToricDestackification";
tier = getenv "TIER"; if tier == "" then tier = "ci";
rows = drop(lines get(currentFileDirectory | "fans.tsv"), 1);
nPass = 0; nFail = 0;
for ln in rows do (
    c := separate("\t", ln);
    id := c#0; rays0 := value c#1; lbl := value c#2; cone := value c#3;
    multB := value c#4; nRays := value c#5; nCones := value c#6;
    if tier != "all" and c#7 != "ci" then continue;
    t0 := currentTime();
    F := stackyFan(rays0, lbl, {cone});
    m := coneMultiplicity(F, cone);
    destackify F;
    R := stackyRays F;
    n := #(rays0#0);
    -- independent checks (rank n, full-dimensional cones)
    unimodular := all(maximalCones F, s -> abs det matrix(R_s) == 1);
    -- every output ray is a non-negative rational combination of the original rays
    A := inverse promote(transpose matrix rays0, QQ);
    inCone := all(R, r -> all(flatten entries(A * transpose promote(matrix{r}, QQ)), x -> x >= 0));
    keeps := take(R, #rays0) == rays0;
    ok := (m == multB) and isSmoothStackyFan F and unimodular and inCone and keeps
          and #R == nRays and #(maximalCones F) == nCones;
    if ok then nPass = nPass + 1 else (
        nFail = nFail + 1;
        << "FAIL " << id << ": mult " << m << " (exp " << multB << "), rays " << #R << " (exp " << nRays
           << "), cones " << #(maximalCones F) << " (exp " << nCones << "), unimodular " << unimodular
           << ", rays in cone " << inCone << ", original rays kept " << keeps << endl);
    << "  " << id << ": " << #R << " rays, " << #(maximalCones F) << " cones, " << currentTime() - t0 << " s" << endl);
<< "fan catalog (tier " << tier << "): " << nPass << " passed, " << nFail << " failed" << endl;
if nFail > 0 then exit 1;
