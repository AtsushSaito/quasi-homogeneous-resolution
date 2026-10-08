-- global2 S1: the atlas yCharts(f, w) and GradedChart.
--   M2 --script tests/m2/test_global2_s1.m2                       the tier-ci samples of the catalog
--   G2_SET=confirm M2 --script tests/m2/test_global2_s1.m2        all 361 CONFIRM samples (+ the SKIP ones are
--                                                                 checked for homogeneity only with G2_SET=all)
--   G2_ONLY=E8_p2,D4_p3 M2 --script ...                           selected samples
-- Expected values below are derived by hand from the definition (chart x_i = 1, A = Z/w_i, deg x_j = w_j,
-- deg s = -1, divisor E = (s)); the catalog/qhReport data are the independent side of the strata check.
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
ok("A = Z/w_i: relation matrix", apply(cs, C -> C#"L") == apply({10,6,15}, a -> matrix{{a}}));
ok("degrees of variables, chart x", cs#0#"degs" == {{6},{15},{-1}});
ok("degrees of variables, chart y", cs#1#"degs" == {{10},{15},{-1}});
ok("degrees of variables, chart z", cs#2#"degs" == {{10},{6},{-1}});
ok("each chart has n variables (n-1 coordinates and s)", all(cs, C -> numgens C#"ring" == 3));
ok("divisor E = (s), s the last variable", all(cs, C -> #C#"divisors" == 1 and (first C#"divisors")#0 == "E" and (first C#"divisors")#1 == last gens C#"ring"));
ok("chart x: equation z^2 + y^5 + 1", (
    Rc := cs#0#"ring";
    cs#0#"I" == ideal(Rc_1^2 + Rc_0^5 + 1_Rc)));
ok("the ideal of every chart is homogeneous", all(cs, chartHomogeneousIdeal));
-- chart x (N = 10): s^10 + y^5 is homogeneous of degree 0 (s has degree -1: -10 = 0; y^5: 30 = 0), s^9 + y^5 is not (-9 vs 0)
ok("chartHomogeneous accepts s^10 + y^5", chartHomogeneous(cs#0, (cs#0#"ring")_2^10 + (cs#0#"ring")_0^5));
ok("chartHomogeneous rejects s^9 + y^5", not chartHomogeneous(cs#0, (cs#0#"ring")_2^9 + (cs#0#"ring")_0^5));
ok("chartHomogeneous rejects y + 1 (6 is not 0 mod 10)", not chartHomogeneous(cs#0, (cs#0#"ring")_0 + 1));
ok("zero is homogeneous", chartHomogeneous(cs#0, 0_(cs#0#"ring")));
ok("the chart variables are called yy", all(cs, C -> all(gens C#"ring", v -> match("^yy", toString v))));

-- weights (1,1,1): A = Z/1 is trivial, every element is homogeneous
R = ZZ/3[x,y,z];
cs1 = yCharts(x^3 + y^3 + z^3, {1,1,1});
ok("trivial group: everything homogeneous", all(cs1, C -> chartHomogeneous(C, (C#"ring")_0 + 1)));

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
