-- The four choices that Bergh's step A2 leaves open (psiOrder, a2Extreme, a2Key, a2Interior) in the
-- research code src/StackyFan.m2, all 2^4 = 16 readings.  Checked here, for every reading:
--   * cyclic quotient surface singularities 1/r(1,q), r <= 6: smooth output and, after contracting
--     (-1)-curves, the Hirzebruch-Jung chain;
--   * the cone spanned by e1, e2, (1,1,3) (multiplicity 3): smooth output with 6 rays and 7 maximal cones.
-- The harder cone (1,2,5) is not run here: only some readings finish within minutes, see switches.tsv
-- and scripts/sweep_a2.sh.
--   M2 --script tests/catalog/run_switches.m2        (about 30 s)
load(currentFileDirectory | "../../src/StackyFan.m2")
nPass = 0; nFail = 0;
for po in {"first","last"} do for ae in {"max","min"} do for ak in {"nd-mult","mult-nd"} do for ai in {true,false} do (
    psiOrder = po; a2Extreme = ae; a2Key = ak; a2Interior = ai;
    tag := po | "/" | ae | "/" | ak | "/" | toString ai;
    bad := {};
    for r from 2 to 6 do for q from 1 to r - 1 do if gcd(r,q) == 1 then (
        G := stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}});
        algorithmB G;
        (pp, ii, bs) := chainSF G;
        if not isSmoothSF G or minimalizeChain bs != hjChainSF(r, q) then bad = append(bad, (r,q)));
    F := stackyFan({{1,0,0},{0,1,0},{1,1,3}}, {1,1,1}, {{0,1,2}});
    algorithmB F;
    if not (isSmoothSF F and #F#"rays" == 6 and #F#"maxCones" == 7) then bad = append(bad, "rank3-113");
    if #bad == 0 then nPass = nPass + 1 else (nFail = nFail + 1; << "FAIL " << tag << ": " << bad << endl));
<< "A2 readings: " << nPass << " of 16 passed, " << nFail << " failed" << endl;
if nFail > 0 then exit 1;
