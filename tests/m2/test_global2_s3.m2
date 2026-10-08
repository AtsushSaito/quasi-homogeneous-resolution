-- global2 S3: eigenCoords, local eigencoordinates and tangent characters at the stratum points.
--   M2 --script tests/m2/test_global2_s3.m2                        tier-ci CONFIRM samples (66)
--   G2_SET=surfaces M2 --script tests/m2/test_global2_s3.m2        the 302 surfaces of the plan
--   G2_SET=confirm  M2 --script tests/m2/test_global2_s3.m2        all 361 CONFIRM samples
--   G2_ONLY=E8_p2 M2 --script tests/m2/test_global2_s3.m2          selected samples
-- Acceptance (plan, section 5, S3): the multiset of characters found from the eigenbasis equals the weights
-- `tw` that qhPredict computes (it uses a different route: weights of all coordinates minus the df-direction).
-- Charts with p | w_i/r are avoided; when every chart of K has p | w_i/r the result is flagged.
root = currentFileDirectory | "../../";
load(root | "src/corpus.m2"); load(root | "src/qh.m2");
load(root | "src/global2/charts.m2"); load(root | "src/global2/stab.m2"); load(root | "src/global2/sample.m2");
count = 0;
ok = (label, cond) -> (count = count + 1; if not cond then (<< "FAILED: " << label << endl; exit 1));

-- ---------------------------------------------------------------- chart preference (pure arithmetic)
-- E8, w = (10,6,15), p = 2.  r = 2, K = {x,y}: w_i/r = 5, 3, both odd: order 0,1.
-- r = 3, K = {y,z}: w_y/r = 2 (p divides it), w_z/r = 5: z first.  r = 5, K = {x,z}: w_x/r = 2, w_z/r = 3: z first.
ok("preference r=2", chartPreference({0,1}, {10,6,15}, 2, 2) == ({0,1}, false));
ok("preference r=3", chartPreference({1,2}, {10,6,15}, 3, 2) == ({2,1}, false));
ok("preference r=5", chartPreference({0,2}, {10,6,15}, 5, 2) == ({2,0}, false));
ok("preference in characteristic 0: natural order", chartPreference({1,2}, {10,6,15}, 3, 0) == ({1,2}, false));
ok("no reduced chart: flagged", chartPreference({0,1}, {4,4}, 2, 2) == ({0,1}, true));

-- ---------------------------------------------------------------- E8 in characteristic 2, by hand
-- tangent weights (hand computation, section 6 of docs/MATH.md style): r=2 at K={x,y}: {1,1} (A_1);
-- r=3 at K={y,z}: {1,2} (A_2);  r=5 at K={x,z}: {1,4} (A_4).
R = ZZ/2[x,y,z]; f = z^2 + x^3 + y^5; w = {10,6,15};
rep = qhReport(f, w); pr = qhPredict(f, w, rep);
cs = yCharts(f, w);
expect = hashTable {{0,1} => ({1,1}, 0), {0,2} => ({1,4}, 2), {1,2} => ({1,2}, 2)};   -- K => (characters, chart)
for q in pr#"strata" do (
    e := eigenCoordsForStratum(cs, q);
    (tw0, ch0) := expect#(q#"K");
    ok("E8_p2 K=" | toString q#"K" | ": verdict", e#"verdict" == "EC-OK" and #e#"flags" == 0);
    ok("E8_p2 K=" | toString q#"K" | ": characters (hand value)", e#"tw" == tw0);
    ok("E8_p2 K=" | toString q#"K" | ": chart (preference rule)", e#"chart" == ch0));
-- in the chart x = 1 the point of the stratum r = 5 (y = 0, z = 1, s = 0 in characteristic 2) is a singular
-- point of the chart equation z^2 + y^5 + 1 (all partials vanish there): the flag must be raised.
Rc = cs#0#"ring";
Pt = ideal(Rc_0, Rc_1 + 1, Rc_2);        -- y = 0, z = 1 (= -1), s = 0
e5 = eigenCoords(cs#0, 5, Pt);
ok("singular chart point is flagged", e5#"verdict" == "EC-FLAG" and #e5#"flags" == 1);
-- chart z = 1, stratum r = 3: the rational point y = 1, x = 0, s = 0 of x^3 + y^5 + 1 = 0.  Weights mod 3:
-- x: 1, y: 0, s: 2.  d/dy = y^4 is a unit there, so v0 = y; the eigenbasis is {x, s} with characters {1,2},
-- and the point is rational so nothing needs to be shifted.
Rz = cs#2#"ring";                          -- variables x, y, s
g = first flatten entries gens cs#2#"I";
ok("chart z equation (hand)", g == Rz_0^3 + Rz_1^5 + 1);
e3 = eigenCoords(cs#2, 3, ideal(Rz_0, Rz_1 + 1, Rz_2));
ok("chart z, r=3: eigenbasis", e3#"verdict" == "EC-OK" and e3#"tw" == {1,2} and e3#"v0" == 1 and e3#"coords" == {Rz_0, Rz_2});
-- ---------------------------------------------------------------- corpus: tangent characters vs qhPredict
rowsC = g2Rows(root | "tests/catalog/hypersurfaces.tsv", false);
nSamples = 0; nStrata = 0; nFlag = 0; flagged = {}; mismatches = {}; nPdivChart = 0;
for row in rowsC do (
    s := sampleOf row#"id"; f := s#"f"; w := s#"w";
    rep := qhReport(f, w); pr := qhPredict(f, w, rep);
    charts := yCharts(f, w);
    for q in pr#"strata" do (
        nStrata = nStrata + 1;
        e := eigenCoordsForStratum(charts, q);
        if e#"tw" === null or e#"tw" != sort q#"weights" then mismatches = append(mismatches, (row#"id", q#"K", q#"r", q#"weights", e#"tw", e#"flags"));
        if e#"verdict" != "EC-OK" then (nFlag = nFlag + 1; flagged = append(flagged, (row#"id", q#"K", q#"r", e#"flags"))));
    nSamples = nSamples + 1);
<< endl << "samples " << nSamples << ", stratum components " << nStrata << endl;
<< "tangent characters differing from qhPredict: " << #mismatches << "  " << mismatches << endl;
<< "components with a flag (no reduced chart, or a fallback chart): " << nFlag << "  " << flagged << endl;
<< "test_global2_s3: " << count << " checks passed" << endl;
if #mismatches > 0 then (<< "S3 ACCEPTANCE FAILED" << endl; exit 1);
<< "S3 ACCEPTANCE OK" << endl;
