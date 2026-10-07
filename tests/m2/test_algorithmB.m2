-- Algorithm B on cyclic quotient surface singularities, checked against the
-- Hirzebruch-Jung continued fraction (an independent oracle).
load(currentFileDirectory | "../../src/StackyFan.m2")
stdCone = (r,q) -> stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}});
rmax = 12; for a in commandLine do if match("^rmax=", a) then rmax = value substring(a, 5);
nok = 0; nbad = 0; maxLen = 0; t0 = currentTime();
for r from 2 to rmax do for q from 1 to r-1 do (
    if gcd(r,q) != 1 then continue;
    F := stdCone(r,q);
    algorithmB F;
    if not isSmoothSF F then (<< "FAIL(not smooth) 1/" << r << "(1," << q << ")" << endl; nbad = nbad+1; continue);
    (path, interior, bs) := chainSF F;
    mn := minimalizeChain bs;
    hj := hjChainSF(r,q);
    maxLen = max(maxLen, #bs);
    if mn == hj then nok = nok + 1
    else (nbad = nbad + 1;
        << "MISMATCH 1/" << r << "(1," << q << "): Bergh " << bs << " -> minimal " << mn << " vs HJ " << hj << endl));
<< "cyclic quotients checked: " << nok << " ok, " << nbad << " bad;  longest Bergh chain " << maxLen
   << ";  " << currentTime() - t0 << " s" << endl;
assert(nbad == 0);
<< endl << "Bergh Example 4.1 (k[x1,x2], ZZ/5, weights (1,3)): naive star subdivision never improves." << endl;
G = basicToricStackyFan(5, {1,3});
<< "  start: rays " << G#"rays" << " labels " << G#"labels" << " mult " << multSF(G,{0,1}) << endl;
algorithmB G;
<< "  Algorithm B terminated: smooth = " << isSmoothSF G << ", rays = " << #G#"rays" << endl;
(p2, i2, b2) = chainSF G;
<< "  chain " << b2 << " -> minimal " << minimalizeChain b2 << "  (HJ(5,3) = " << hjChainSF(5,3) << ", HJ(5,2) = " << hjChainSF(5,2) << ")" << endl;
assert(isSmoothSF G);
