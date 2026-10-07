-- Quotient singularities: for p | r, the invariant ring k[x_1..x_m]^{mu_r} (mu_r acting with
-- weights c) is still a normal affine semigroup ring (the mu_r-action is a Z/r-grading; nothing depends on p).
load(currentFileDirectory | "../src/qh.m2")
cases = {(2, 2, {1,1}), (2, 4, {1,3}), (2, 4, {1,1}), (3, 3, {1,2}), (3, 3, {1,1}), (2, 2, {1,1,1}), (3, 3, {1,1,2}), (2, 4, {1,2,3}), (5, 5, {1,2,3}), (2, 8, {1,3,5})};
for c in cases do (
    (p, r, wts) := c; m := #wts;
    kk := ZZ/p; A := kk[apply(m, j -> (getSymbol "t")_j)];
    inv := muInvariantMonomials(wts, r, A);
    S := kk[apply(#inv, k -> (getSymbol "u")_k)];
    phi := map(A, S, inv); I := kernel phi; Q := S/I;
    << "p = " << p << "  mu_" << r << " weights " << wts << (if r % p == 0 then "  (p | r)" else "") << " : " << #inv << " generators " << inv
       << ",  " << numgens I << " relations, dim " << dim Q << ", normal = " << isNormal Q << ", domain = " << isPrime I << endl);
