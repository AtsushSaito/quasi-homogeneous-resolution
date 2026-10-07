-- Imperfect field, characteristic 2:  f = a x^2 + b y^2 + c z^2  over  k = F_2(a, b, c)
-- Illustrates the "smooth vs regular" boundary of assumption A4:
--   (i)   f is nowhere smooth over k  (Jacobian over k vanishes identically)  => A4 fails
--   (ii)  yet X is regular away from the origin (extended Jacobian over the perfect field F_2)
--   (iii) one ordinary blow-up already gives a regular model
--   (iv)  regularity is lost after the inseparable extension k(s), s^2 = a/b  (non-isolated)
banner = s -> (<< endl << "==== " << s << " ====" << endl);

banner "(i) smoothness over k = F_2(a,b,c)"
kk = frac(ZZ/2[a, b, c])
R = kk[x, y, z]
f = a*x^2 + b*y^2 + c*z^2
<< "jacobian over k = " << transpose jacobian f << endl;
J = ideal f + ideal jacobian f
<< "dim V(f, df) = " << dim J << "   (dim X = 2, so X is nowhere smooth over k: A4 FAILS)" << endl;

banner "(ii) regularity via the extended Jacobian over F_2 (a, b, c as variables)"
B = ZZ/2[a, b, c, x, y, z]
F = a*x^2 + b*y^2 + c*z^2
JB = ideal F + ideal jacobian F
<< "extended jacobian = " << transpose jacobian F << endl;
<< "radical of (F, dF) = " << radical JB << endl;
<< "  => non-regular locus of the total space is the section {x=y=z=0};" << endl;
<< "     its generic fibre over F_2(a,b,c) is the origin: X is regular away from v." << endl;

banner "(iii) one blow-up: chart y = x u, z = x v, strict transform a + b u^2 + c v^2"
B2 = ZZ/2[a, b, c, u, v]
G = a + b*u^2 + c*v^2
JG = ideal G + ideal jacobian G
<< "extended jacobian = " << transpose jacobian G << endl;
<< "(G, dG) is the unit ideal: " << (JG == ideal 1_B2) << "   => the strict transform is regular everywhere" << endl;

banner "(iv) after the inseparable extension s^2 = a/b the cone is no longer isolated"
B3 = ZZ/2[s, b, c, x, y, z]
F3 = s^2*b*x^2 + b*y^2 + c*z^2      -- = b (s x + y)^2 + c z^2
J3 = ideal F3 + ideal jacobian F3
<< "radical of (F3, dF3) = " << radical J3 << "   (a line: regularity is not stable under inseparable base change)" << endl;
