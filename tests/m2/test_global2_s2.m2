-- global2 S2: fixedLoci(chart), the stabiliser loci Z_r of the charts.
--   M2 --script tests/m2/test_global2_s2.m2                        tier-ci CONFIRM samples (66)
--   G2_SET=confirm M2 --script tests/m2/test_global2_s2.m2         all 361 CONFIRM samples
--   G2_ONLY=E8_p2 M2 --script tests/m2/test_global2_s2.m2          selected samples
-- Acceptance criteria of the plan (section 5, S2), checked here WITHOUT relaxation, on the cone atlas yCharts
-- (grading group Z; chosen over the slice atlas, which fails (b) for p | w_i):
--   (a) the set of r that occur (union over the charts) equals the set of orders of qhReport and the
--       column expected_strata_orders of tests/catalog/hypersurfaces.tsv;
--   (b) every Z_r of every chart passes the Jacobian test.
-- The slice atlas ySliceCharts is run as a diagnostic only: it is expected to FAIL (b) for p | w_i.
root = currentFileDirectory | "../../";
load(root | "src/corpus.m2"); load(root | "src/qh.m2");
load(root | "src/global2/charts.m2"); load(root | "src/global2/stab.m2"); load(root | "src/global2/sample.m2");
count = 0;
ok = (label, cond) -> (count = count + 1; if not cond then (<< "FAILED: " << label << endl; exit 1));

-- ---------------------------------------------------------------- hand-derived unit checks
-- E8 in char 2, w = (10,6,15), d = 30, cone chart x (N = 10, variables x, y, z, s, x' of degrees 10, 6, 15, -1, -10).
-- The divisors r > 1 of 10 are 2, 5, 10.
--   Z_2 = {x^3 + y^5 = 0, z = s = 0, x x' = 1}: z and s have odd degree.  Smooth, because d/dx = x^2 is a unit;
--   Z_10 needs y = z = s = 0 and then the equation is x^3 = 0 with x a unit: empty;
--   Z_5 = {y = s = 0, z^2 + x^3 = 0, x x' = 1}: smooth for the same reason (d/dx = x^2).
--   So the orders occurring in this chart are 2 and 5.
R = ZZ/2[x,y,z]; f = z^2 + x^3 + y^5; w = {10,6,15};
cs = yCharts(f, w);
fl0 = fixedLoci cs#0;
ok("E8_p2 cone chart x: Z_r for r = 2, 5 only", sort keys fl0#"Z" == {2,5});
ok("E8_p2 cone chart x: orders {2,5}", fl0#"rSet" == {2,5});
ok("E8_p2 cone chart x: Z_2 and Z_5 smooth (hand computation)", all(values fl0#"smooth", v -> v == "SMOOTH"));
ok("E8_p2 chart y (N = 6): orders {2,3}", (fixedLoci cs#1)#"rSet" == {2,3});
ok("E8_p2 chart z (N = 15): orders {3,5}", (fixedLoci cs#2)#"rSet" == {3,5});
ok("E8_p2 chart z: Z_3, Z_5 smooth", all(values (fixedLoci cs#2)#"smooth", v -> v == "SMOOTH"));
-- The slice chart x = 1 has Z_5 = {z^2 + 1 = (z+1)^2 = 0} in characteristic 2: a double point, NOT-SMOOTH.
-- This is the reason for the cone atlas.
ss = ySliceCharts(f, w);
ok("E8_p2 slice chart x: Z_5 is the double point (z+1)^2 (hand computation)", (fixedLoci ss#0)#"smooth"#5 == "NOT-SMOOTH");
R = QQ[x,y,z]; cs = yCharts(z^2 + x^3 + y^5, {10,6,15});
ok("E8 over QQ: all Z_r of all charts smooth", all(cs, C -> all(values (fixedLoci C)#"smooth", v -> v == "SMOOTH")));
ok("E8 over QQ: orders {2,3,5} in total", sort unique flatten apply(cs, C -> (fixedLoci C)#"rSet") == {2,3,5});
-- weights (1,1,1): N = 1, no r > 1
R = ZZ/3[x,y,z]; cs = yCharts(x^3 + y^3 + z^3, {1,1,1});
ok("trivial stabilisers: no loci", all(cs, C -> #(fixedLoci C)#"Z" == 0 and (fixedLoci C)#"rSet" == {}));

-- ---------------------------------------------------------------- corpus
catRows = g2Rows(root | "tests/catalog/hypersurfaces.tsv", false);
nSamples = 0; nZ = 0; nZsmooth = 0; nZnot = 0; nZerr = 0; nNotPdivides = 0; nNotPnot = 0; mismatches = {}; failures = {};
nCone = 0; nConeSmooth = 0; coneMismatch = {};
unionSet = L -> sort unique flatten L;
for row in catRows do (
    s := sampleOf row#"id"; f := s#"f"; w := s#"w"; p := s#"p"; n := s#"n";
    rep := qhReport(f, w);
    expected := unionSet apply(rep#"strata", st -> {st#"r"});
    expectedCat := sort unique (value row#"expected_strata_orders");
    ok(row#"id" | ": qhReport and the catalog column agree", expected == expectedCat);
    charts := yCharts(f, w);
    fls := apply(charts, fixedLoci);
    sfls := apply(ySliceCharts(f, w), fixedLoci);
    got := unionSet apply(fls, fl -> fl#"rSet");
    if got != expected then mismatches = append(mismatches, (row#"id", expected, got));
    -- the support-pattern enumeration gives the same orders (small charts)
    if n <= 4 then for k from 0 to n-1 do (
        pats := stabiliserPatterns charts#k;
        ok(row#"id" | ": chart " | toString k | ": patterns and divisors give the same orders", sort unique apply(pats, h -> h#"r") == fls#k#"rSet"));
    for k from 0 to n-1 do for r in sort keys fls#k#"smooth" do (
        nZ = nZ + 1;
        v := fls#k#"smooth"#r;
        if v == "SMOOTH" then nZsmooth = nZsmooth + 1
        else (
            if v == "ERROR" then nZerr = nZerr + 1 else nZnot = nZnot + 1;
            failures = append(failures, (row#"id", k, r, v))));
    -- diagnostic: the slice atlas
    sgot := unionSet apply(sfls, fl -> fl#"rSet");
    if sgot != expected then coneMismatch = append(coneMismatch, (row#"id", expected, sgot));
    for k from 0 to n-1 do for r in keys sfls#k#"smooth" do (
        nCone = nCone + 1; if sfls#k#"smooth"#r == "SMOOTH" then nConeSmooth = nConeSmooth + 1);
    nSamples = nSamples + 1);
<< endl << "samples: " << nSamples << endl;
<< "(a) order sets: " << (nSamples - #mismatches) << " of " << nSamples << " agree with qhReport; mismatches " << mismatches << endl;
<< "(b) Z_r in cone charts: " << nZ << " loci, smooth " << nZsmooth << ", NOT-SMOOTH " << nZnot << ", ERROR " << nZerr << endl;
<< "    failures (sample, chart, r, verdict): " << failures << endl;
<< "(diagnostic) slice atlas: order sets disagree for " << coneMismatch << "; Z_r smooth " << nConeSmooth << " of " << nCone << endl;
<< "test_global2_s2: " << count << " checks passed" << endl;
if #mismatches > 0 or #failures > 0 then (<< "S2 ACCEPTANCE FAILED" << endl; exit 1);
<< "S2 ACCEPTANCE OK" << endl;
