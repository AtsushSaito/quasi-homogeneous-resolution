-- C8: beyond hypersurfaces
load(currentFileDirectory | "../src/qh.m2")
for p in {2,3,5} do (
    banner("C8-1 (H9): cone over the rational quartic curve (x^4, x^3 y, x y^3, y^4), non-normal domain, char " | p);
    kk := ZZ/p; S := kk[s,t]; R := kk[a,b,c,d];
    I := kernel map(S, R, {s^4, s^3*t, s*t^3, t^4});
    << "ideal of X: " << I << endl;
    << "normal (X) : " << isNormal(R/I) << endl;
    toricResolveIdeal(I, {1,1,1,1}));
banner "C8-2: complete intersection of two quadrics in A^5, char 7 (cone over a degree-4 del Pezzo surface)";
kk = ZZ/7; R = kk[x1,x2,x3,x4,x5];
I = ideal(x1^2 + x2^2 + x3^2 + x4^2 + x5^2, x2^2 + 2*x3^2 + 3*x4^2 + 4*x5^2);
toricResolveIdeal(I, {1,1,1,1,1});
banner "C8-3: weighted complete intersection in A^4, char 3:  (x^2 + y^2 + z^3,  x*y + u^3), w = (3,3,2,2)";
kk = ZZ/3; R = kk[x,y,z,u];
I = ideal(x^2 + y^2 + z^3, x*y + u^3);
toricResolveIdeal(I, {3,3,2,2});
