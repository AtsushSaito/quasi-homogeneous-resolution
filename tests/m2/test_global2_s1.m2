-- global2 S1: the atlas yCharts(f, w) and GradedChart.
--   M2 --script tests/m2/test_global2_s1.m2                       the tier-ci samples of the catalog
--   G2_SET=confirm M2 --script tests/m2/test_global2_s1.m2        all 361 CONFIRM samples (+ the SKIP ones are
--                                                                 checked for homogeneity only with G2_SET=all)
--   G2_ONLY=E8_p2,D4_p3 M2 --script ...                           selected samples
-- Cone atlas (decision: cone charts).  Expected values below are derived by hand from the definition
-- (chart k[x_0..x_{n-1}, s, x_i'] / (f, x_i x_i' - 1), A = Z, deg x_j = w_j, deg s = -1, deg x_i' = -w_i,
-- divisor E = (s)); the catalog/qhReport data are the independent side of the strata check.
root = currentFileDirectory | "../../";
load(root | "src/corpus.m2"); load(root | "src/qh.m2");
load(root | "src/global2/charts.m2"); load(root | "src/global2/sample.m2");
count = 0;
ok = (label, cond) -> (count = count + 1; if not cond then (<< "FAILED: " << label << endl; exit 1));
fails = thunk -> (try (thunk(); false) else true);

-- ---------------------------------------------------------------- E8 in characteristic 2, by hand
R = ZZ/2[x,y,z];
f = z^2 + x^3 + y^5;
cs = yCharts(f, {10,6,15});
ok("three charts", #cs == 3);
ok("orders N = w_i", apply(cs, C -> C#"N") == {10, 6, 15});
ok("A = Z: no relations", all(cs, C -> C#"L" == 0));
ok("degrees of variables, chart x", cs#0#"degs" == {{10},{6},{15},{-1},{-10}});
ok("degrees of variables, chart y", cs#1#"degs" == {{10},{6},{15},{-1},{-6}});
ok("degrees of variables, chart z", cs#2#"degs" == {{10},{6},{15},{-1},{-15}});
ok("each chart has n + 2 variables (x_0..x_{n-1}, s, x_i')", all(cs, C -> numgens C#"ring" == 5));
ok("divisor E = (s), s = yy_n", all(cs, C -> #C#"divisors" == 1 and (first C#"divisors")#0 == "E" and (first C#"divisors")#1 == (C#"ring")_3));
ok("chart x: ideal (z^2 + x^3 + y^5, x x' - 1)", (
    Rc := cs#0#"ring";
    cs#0#"I" == ideal(Rc_2^2 + Rc_0^3 + Rc_1^5, Rc_0*Rc_4 - 1_Rc)));
ok("the ideal of every chart is homogeneous", all(cs, chartHomogeneousIdeal));
-- Z-grading, chart x: s^10 x^... : deg(s^10 x) = -10 + 10 = 0 is homogeneous of degree 0; s^9 + y has degrees -9 and 6
ok("chartHomogeneous accepts s^10 x + 1 (degrees 0 and 0)", chartHomogeneous(cs#0, (cs#0#"ring")_3^10 * (cs#0#"ring")_0 + 1));
ok("chartHomogeneous rejects s^9 + y^5", not chartHomogeneous(cs#0, (cs#0#"ring")_3^9 + (cs#0#"ring")_1^5));
ok("chartHomogeneous rejects y + 1 (6 != 0)", not chartHomogeneous(cs#0, (cs#0#"ring")_1 + 1));
ok("zero is homogeneous", chartHomogeneous(cs#0, 0_(cs#0#"ring")));
ok("the chart variables are called yy", all(cs, C -> all(gens C#"ring", v -> match("^yy", toString v))));

-- weights (1,1,1): the grading group is Z, so x + 1 is not homogeneous
R = ZZ/3[x,y,z];
cs1 = yCharts(x^3 + y^3 + z^3, {1,1,1});
ok("weights 1: x + 1 is not homogeneous for A = Z", not chartHomogeneous(cs1#0, (cs1#0#"ring")_0 + 1));

-- ---------------------------------------------------------------- invalid input: errors and verdicts
R = QQ[x,y,z];
ok("f not quasi-homogeneous: error", fails(() -> yCharts(x + y^2, {1,1,1})));
ok("f not quasi-homogeneous: verdict", (tryYCharts(x + y^2, {1,1,1}))#"verdict" == "G2-ERROR");
ok("weight 0: error", fails(() -> yCharts(x*y + z^2, {1,1,0})));
ok("negative weight: verdict", (tryYCharts(x*y + z^2, {1,-1,0}))#"verdict" == "G2-ERROR");
ok("wrong number of weights: verdict", (tryYCharts(x*y + z^2, {1,1}))#"verdict" == "G2-ERROR");
ok("f = 0: verdict", (tryYCharts(0_R, {1,1,1}))#"verdict" == "G2-ERROR");
ok("valid input: verdict", (tryYCharts(x*y + z^2, {1,1,1}))#"verdict" == "G2-OK");

-- ---------------------------------------------------------------- corpus: homogeneity, strata
rows = g2Rows(root | "tests/catalog/hypersurfaces.tsv", getenv "G2_SET" == "all");
nStrata = 0; nSamples = 0;
for row in rows do (
    s := sampleOf row#"id"; f := s#"f"; w := s#"w";
    charts := yCharts(f, w);                                   -- asserts homogeneity chart by chart
    ok(row#"id" | ": n charts", #charts == s#"n");
    ok(row#"id" | ": N = w_i", apply(charts, C -> C#"N") == w);
    ok(row#"id" | ": homogeneous", all(charts, chartHomogeneousIdeal));
    if row#"expected_verdict" != "CONFIRM" then continue;
    rep := qhReport(f, w);
    for st in rep#"strata" do (
        nStrata = nStrata + 1;
        K := st#"K";
        inCharts := select(toList(0..s#"n"-1), i -> chartContainsStratum(charts#i, st));
        ok(row#"id" | ": stratum " | toString K | " lies in at least one chart", #inCharts >= 1);
        ok(row#"id" | ": stratum " | toString K | " lies exactly in the charts i in K", inCharts == sort K));
    nSamples = nSamples + 1);
<< "test_global2_s1: " << count << " checks passed (" << nSamples << " CONFIRM samples, " << nStrata << " strata)" << endl;
