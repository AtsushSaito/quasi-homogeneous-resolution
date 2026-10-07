-- Properness of T -> A^n, decided by exact combinatorics rather than by sampling points.
--
-- Cox-Little-Schenck, Toric Varieties, Theorem 3.4.11: a toric morphism X_Sigma -> X_Sigma' is
-- proper exactly when phi_R^{-1}(|Sigma'|) = |Sigma|.  Here Sigma' is the orthant, phi is the
-- identity, and the condition says the fan refines the orthant and covers all of it.  That is
-- checked by refinesOrthantExact: every maximal cone is spanned by n linearly independent rays,
-- every ray lies in the closed orthant, every standard basis vector is a ray, every wall on the
-- boundary of the orthant lies in exactly one maximal cone, every interior wall in exactly two,
-- and the dual graph is connected.  All of it is integer arithmetic, so the answer is a proof and
-- not a sample.
load(currentFileDirectory | "../../src/qh.m2")
samples = {("E8_p2", 2, 3, {10,6,15}), ("dim4mixed_p3", 3, 5, {3,3,3,2,1}),
           ("surfmu3_p3", 3, 5, {3,3,3,3,1}), ("nwf2221_p2", 2, 4, {2,2,2,1})};
allOk = true;
for s in samples do (
    (nm, p, n, w) := s;
    X2 := makeSmooth toricBlowup(toList(0..n-1), affineSpace n, w);
    << nm << " (n = " << n << ", w = " << w << "):  " << #rays X2 << " rays, "
       << #max X2 << " cones, isSmooth " << isSmooth X2 << endl;
    assert isSmooth X2;
    (ok, notes) := refinesOrthantExact(rays X2, max X2);
    for t in notes do << "    " << t << endl;
    << "  => T -> A^n proper : " << ok << endl;
    if not ok then allOk = false);
<< endl << "all fans refine the orthant exactly: " << allOk << endl;
-- Assert, do not merely print.  Without this the script exits 0 on a failure and any shell
-- driver reads the run as a pass.
assert allOk;
