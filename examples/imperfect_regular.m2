-- C7: regular-but-not-smooth cones over k = F_2(a,b,...) (H8).  Parameters first, then x, y, z.
load(currentFileDirectory | "../src/qh.m2")
banner "C7-1: a x^2 + b y^2 + c z^2, w = (1,1,1)   [nowhere smooth over k, regular away from v]"
B = (ZZ/2)[a,b,c,x,y,z]; toricResolveRegular(a*x^2 + b*y^2 + c*z^2, {1,1,1}, 3);
banner "C7-2: a x^2 + b y^4 + c z^4, w = (2,1,1)   [no stabilisers on X; mu_2 acts freely on the chart]"
B = (ZZ/2)[a,b,c,x,y,z]; toricResolveRegular(a*x^2 + b*y^4 + c*z^4, {2,1,1}, 3);
banner "C7-3: x^2 + a y^2 + b z^4, w = (2,2,1)   [mu_2 point with residue field k(sqrt a): Bergh Ex. A.5 phenomenon]"
B = (ZZ/2)[a,b,x,y,z]; toricResolveRegular(x^2 + a*y^2 + b*z^4, {2,2,1}, 2);
banner "C7-4: a x^2 + b y^2 + c z^2 + e u^2, w = (1,1,1,1)"
B = (ZZ/2)[a,b,c,e,x,y,z,u]; toricResolveRegular(a*x^2 + b*y^2 + c*z^2 + e*u^2, {1,1,1,1}, 4);
banner "C7-5 (control): b (s x + y)^2 + c z^2 = s^2 b x^2 + b y^2 + c z^2   [non-isolated after adjoining s = sqrt(a/b)]"
B = (ZZ/2)[s,b,c,x,y,z]; toricResolveRegular(s^2*b*x^2 + b*y^2 + c*z^2, {1,1,1}, 3);
banner "C7-6: char 3 analogue  a x^3 + b y^3 + c z^3, w = (1,1,1)"
B = (ZZ/3)[a,b,c,x,y,z]; toricResolveRegular(a*x^3 + b*y^3 + c*z^3, {1,1,1}, 3);
banner "C7-7: char 3 with stabilisers  x^3 + a y^3 + b z^6 ... use x^2 + a y^6 + b z^3? weights: try a x^3 + y^2 + b z^6, w=(2,3,1)"
B = (ZZ/3)[a,b,x,y,z]; toricResolveRegular(a*x^3 + y^2 + b*z^6, {2,3,1}, 2);
