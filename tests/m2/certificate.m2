-- A complete certificate for ONE global resolution, in dimension 4 (where existence is not
-- classically known).  Nothing here cites a theorem about resolution: every claim is checked.
load(currentFileDirectory | "../../src/qh.m2")
p = 3; n = 5;
R = (ZZ/p)[x,y,z,u,v];
f = x^2 + y^2 + z^2 + u^2 + v^6;
w = {3,3,3,3,1};
<< "X = Spec k[x,y,z,u,v]/(" << f << "),  k = F_" << p << ",  dim X = " << n-1 << endl;
<< "weights " << w << ", weighted degree 6" << endl << endl;

<< "(0) A4: X is smooth away from the vertex." << endl;
J = ideal f + ideal jacobian f;
<< "    dim V(f, df) = " << dim J << "  (0 = the vertex only)" << endl << endl;

T = makeSmooth toricBlowup(toList(0..n-1), affineSpace n, w);
rayList = rays T; coneList = max T;
<< "(1) The ambient toric variety T: " << #rayList << " rays, " << #coneList << " maximal cones." << endl;
<< "    rays = " << rayList << endl;
<< "    every maximal cone has determinant +-1 (T is smooth): "
   << all(coneList, c -> abs det matrix rayList_c == 1) << endl << endl;

<< "(2) T -> A^5 is proper: the fan refines the orthant." << endl;
<< "    "; checkRefinesOrthant(rayList, coneList, Trials => 60);
<< endl;

<< "(3) T -> A^5 is an isomorphism away from the origin: every added ray is interior." << endl;
basisVecs = entries id_(ZZ^n);
added = select(rayList, r -> not member(r, basisVecs));
<< "    added rays " << added << ", all strictly positive: " << all(added, r -> all(r, c -> c > 0)) << endl << endl;

<< "(4) The strict transform X~ is smooth in every chart of T." << endl;
Y = (ZZ/p)[yy_0..yy_4];
bad = {}; exc = {};
for sigma in coneList do (
    V := rayList_sigma;
    g := sub(f, matrix{ apply(n, i -> product(n, j -> Y_j^(V#j#i))) });
    e := exponents g;
    mono := product(n, j -> Y_j^(min apply(e, t -> t#j)));
    ft := g // mono;
    if dim(ideal ft + ideal jacobian ft) >= 0 then bad = append(bad, (sigma, ft));
    for a from 0 to n-1 do if all(V#a, c -> c > 0) and dim(ideal ft + ideal Y_a) >= 0 then exc = append(exc, sigma#a));
<< "    charts checked: " << #coneList << ",  charts where X~ is singular: " << #bad << endl;
if #bad > 0 then for b in bad do << "      " << b << endl;
<< "    exceptional divisors meeting X~: " << #unique exc << " (rays " << apply(sort unique exc, i -> rayList#i) << ")" << endl << endl;

assert(#bad == 0);
<< "CONCLUSION: X~ is a smooth 4-fold, proper and birational over X, isomorphic over X minus the" << endl;
<< "vertex.  That is a global resolution of X, exhibited without citing any resolution theorem." << endl;
