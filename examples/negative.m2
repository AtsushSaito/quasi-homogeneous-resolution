-- Negative controls: A4 must be reported as FAIL and M must not be applied.
load(currentFileDirectory | "../src/qh.m2")
R = (ZZ/2)[x, y, z]
qhVerify(x^2 + y^2 + z^2, {1, 1, 1})      -- char 2 quadric: (x+y+z)^2, non-reduced
R = (ZZ/3)[x, y, z]
qhVerify(x^3 + y^3 + z^3, {1, 1, 1})      -- char 3 cubic: (x+y+z)^3
R = (ZZ/2)[x, y, z]
-- not quasi-homogeneous for these weights: Q1 must be rejected with an error
try qhVerify(z^2 + x^2*y + y^3 + x^5, {2, 2, 3}) else << endl << "Q1 rejected as expected (x^5 has weighted degree 10, the rest 6)" << endl;
