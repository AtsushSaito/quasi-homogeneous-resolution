-- E_8^0 in characteristic 2:  z^2 + x^3 + y^5,  w = (10, 6, 15),  d = 30
-- p = 2 divides w_x = 10, w_y = 6 and d = 30.  Expected:
--   strata mu_3 (x=0), mu_5 (y=0), mu_2 (z=0)  [mu_2 infinitesimal]
--   X' has A_2, A_4, A_1 points; resolution has 8 exceptional curves, dual graph E_8
load(currentFileDirectory | "../src/qh.m2")
kk = ZZ/2
R = kk[x, y, z]
f = z^2 + x^3 + y^5
w = {10, 6, 15}
qhVerify(f, w)
