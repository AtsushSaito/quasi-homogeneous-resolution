load(currentFileDirectory | "../../src/StackyFan.m2")
stdCone = (r,q) -> stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}});
nok = 0; nbad = 0;
for r from 2 to 8 do for q from 1 to r-1 do (
    if gcd(r,q) != 1 then continue;
    F := stdCone(r,q); algorithmB F;
    (path, interior, bs) := chainSF F;
    if minimalizeChain bs == hjChainSF(r,q) then nok = nok+1
    else (nbad = nbad+1; << "MISMATCH 1/" << r << "(1," << q << "): " << minimalizeChain bs << " vs " << hjChainSF(r,q) << endl));
<< "dim 2 cyclic quotients r<=8 vs Hirzebruch-Jung: " << nok << " ok, " << nbad << " bad" << endl;
assert(nbad == 0 and nok == 21);
