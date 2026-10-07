-- 3-fold in characteristic 3:  x1^2 + x2^2 + x3^3 + x3*x4^4 + x4^6,  w = (3,3,2,1),  d = 6
-- p = 3 divides w_1, w_2 and d.  Stratum {x3 = x4 = 0} has stabilizer mu_3 (infinitesimal).
load(currentFileDirectory | "../src/qh.m2")
kk = ZZ/3
R = kk[x1, x2, x3, x4]
f = x1^2 + x2^2 + x3^3 + x3*x4^4 + x4^6
w = {3, 3, 2, 1}
qhVerify(f, w)
