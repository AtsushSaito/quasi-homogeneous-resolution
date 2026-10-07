-- 4-fold in characteristic 3:  x1^2 + x2^2 + x3^2 + x4^3 + x4*x5^4 + x5^6,  w = (3,3,3,2,1),  d = 6
-- p = 3 divides w_1, w_2, w_3 and d.  The mu_3 stratum {x4 = x5 = 0} is a conic (1-dimensional),
-- so Sing(X') is positive-dimensional.  L2 must still give a smooth strict transform.
load(currentFileDirectory | "../src/qh.m2")
kk = ZZ/3
R = kk[x1, x2, x3, x4, x5]
f = x1^2 + x2^2 + x3^2 + x4^3 + x4*x5^4 + x5^6
w = {3, 3, 3, 2, 1}
qhVerify(f, w)
