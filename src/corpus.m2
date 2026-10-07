-- corpus.m2 -- sample library for the M-verification program.
-- Each sample: name, family, p, n, f (string in x,y,z,u,v), w, tags, expectArms (surfaces, sorted arm
-- lengths or null), expectCurves, expectSelf (list or null), expectGenus.

mk = (name, family, p, n, fstr, w, tags, opts) -> (
    h := new MutableHashTable from {"name" => name, "family" => family, "p" => p, "n" => n, "f" => fstr, "w" => w, "tags" => tags,
        "expectArms" => null, "expectCurves" => null, "expectSelf" => null, "expectGenus" => null};
    for o in opts do h#(o#0) = o#1;
    new HashTable from h)

allminus2 = k -> toList(k : 2);

corpus = {};

-- ---------------- C1: Artin's rational double points, quasi-homogeneous forms
for p in {2,3,5,7} do (
    for nn in {1,2,3,4,5,6,7} do
        corpus = append(corpus, mk("A" | nn | "_p" | p | "_w1n1", "C1", p, 3, "x*y + z^" | (nn+1), {1, nn, 1}, "RDP A" | nn,
            {("expectArms", if nn == 1 then {} else {nn-1}), ("expectCurves", nn), ("expectSelf", allminus2 nn), ("expectGenus", 0)}));
    for nn in {3,5,7,9} do (
        h := (nn+1)//2;
        corpus = append(corpus, mk("A" | nn | "_p" | p | "_whh1", "C1", p, 3, "x*y + z^" | (nn+1), {h, h, 1}, "RDP A" | nn | " alt weights (F6)",
            {("expectArms", {h-1, h-1}), ("expectCurves", nn), ("expectSelf", allminus2 nn), ("expectGenus", 0)})));
    if p != 2 then for nn in {4,5,6,7,8} do
        corpus = append(corpus, mk("D" | nn | "_p" | p, "C1", p, 3, "z^2 + x^2*y + y^" | (nn-1), {nn-2, 2, nn-1}, "RDP D" | nn,
            {("expectArms", sort {1, 1, nn-3}), ("expectCurves", nn), ("expectSelf", allminus2 nn), ("expectGenus", 0)}));
    if p == 2 then (
        for m in {2,3,4} do
            corpus = append(corpus, mk("D" | (2*m) | "0_p2", "C1", 2, 3, "z^2 + x^2*y + x*y^" | m, {2*(m-1), 2, 2*m-1}, "Artin D_{2m}^0 char 2",
                {("expectArms", sort {1, 1, 2*m-3}), ("expectCurves", 2*m), ("expectSelf", allminus2 (2*m)), ("expectGenus", 0)}));
        for m in {2,3} do
            corpus = append(corpus, mk("D" | (2*m+1) | "0_p2", "C1", 2, 3, "z^2 + x^2*y + y^" | m | "*z", {2*m-1, 2, 2*m}, "Artin D_{2m+1}^0 char 2",
                {("expectArms", sort {1, 1, 2*m-2}), ("expectCurves", 2*m+1), ("expectSelf", allminus2 (2*m+1)), ("expectGenus", 0)})));
    if p != 2 then corpus = append(corpus, mk("E6_p" | p, "C1", p, 3, "z^2 + x^3 + y^4", {4,3,6}, "RDP E6",
        {("expectArms", {1,2,2}), ("expectCurves", 6), ("expectSelf", allminus2 6), ("expectGenus", 0)}));
    if p == 2 then corpus = append(corpus, mk("E60_p2", "C1", 2, 3, "z^2 + x^3 + y^2*z", {4,3,6}, "Artin E6^0 char 2",
        {("expectArms", {1,2,2}), ("expectCurves", 6), ("expectSelf", allminus2 6), ("expectGenus", 0)}));
    corpus = append(corpus, mk("E7_p" | p, "C1", p, 3, "z^2 + x^3 + x*y^3", {6,4,9}, "RDP E7",
        {("expectArms", {1,2,3}), ("expectCurves", 7), ("expectSelf", allminus2 7), ("expectGenus", 0)}));
    corpus = append(corpus, mk("E8_p" | p, "C1", p, 3, "z^2 + x^3 + y^5", {10,6,15}, "RDP E8",
        {("expectArms", {1,2,4}), ("expectCurves", 8), ("expectSelf", allminus2 8), ("expectGenus", 0)})));

-- ---------------- C2: Brieskorn-Pham surfaces x^a + y^b + z^c
for p in {2,3,5,7} do for a from 2 to 7 do for b from a to 7 do for c from b to 7 do (
    d := lcm(lcm(a,b),c);
    corpus = append(corpus, mk("BP" | a | b | c | "_p" | p, "C2", p, 3, "x^" | a | " + y^" | b | " + z^" | c, {d//a, d//b, d//c}, "Brieskorn-Pham d=" | d, {})));

-- ---------------- C3: Arnold's exceptional unimodal singularities (quasi-homogeneous representatives)
arnold = {("E12", "x^3 + y^7 + z^2", {14,6,21}), ("E13", "x^3 + x*y^5 + z^2", {10,4,15}), ("E14", "x^3 + y^8 + z^2", {8,3,12}),
          ("Z11", "x^3*y + y^5 + z^2", {8,6,15}), ("Z12", "x^3*y + x*y^4 + z^2", {6,4,11}), ("Z13", "x^3*y + y^6 + z^2", {5,3,9}),
          ("W12", "x^4 + y^5 + z^2", {5,4,10}), ("W13", "x^4 + x*y^4 + z^2", {4,3,8}),
          ("Q10", "x^3 + y^4 + y*z^2", {8,6,9}), ("Q11", "x^3 + y^2*z + x*z^3", {6,7,4}), ("Q12", "x^3 + y^5 + y*z^2", {5,3,6}),
          ("S11", "x^4 + y^2*z + x*z^2", {4,5,6}), ("S12", "x^2*y + y^2*z + x*z^3", {4,5,3}), ("U12", "x^3 + y^3 + z^4", {4,4,3})};
for p in {2,3,5,7} do for t in arnold do
    corpus = append(corpus, mk(t#0 | "_p" | p, "C3", p, 3, t#1, t#2, "Arnold exceptional unimodal", {}));

-- ---------------- C4: simple elliptic
for p in {2,3,5,7} do (
    corpus = append(corpus, mk("Et6_p" | p, "C4", p, 3, "x^3 + y^3 + z^3", {1,1,1}, "simple elliptic Etilde6",
        {("expectArms", {}), ("expectCurves", 1), ("expectSelf", {3}), ("expectGenus", 1)}));
    corpus = append(corpus, mk("Et7_p" | p, "C4", p, 3, "x^4 + y^4 + z^2", {1,1,2}, "simple elliptic Etilde7",
        {("expectArms", {}), ("expectCurves", 1), ("expectSelf", {2}), ("expectGenus", 1)}));
    corpus = append(corpus, mk("Et8_p" | p, "C4", p, 3, "x^6 + y^3 + z^2", {1,2,3}, "simple elliptic Etilde8",
        {("expectArms", {}), ("expectCurves", 1), ("expectSelf", {1}), ("expectGenus", 1)})));

-- ---------------- C5: threefolds
for p in {2,3,5,7} do (
    for k from 2 to 6 do (d := lcm(2,k); corpus = append(corpus, mk("BP222" | k | "_p" | p, "C5", p, 4, "x^2 + y^2 + z^2 + u^" | k, {d//2, d//2, d//2, d//k}, "3-fold BP", {})));
    for k from 3 to 5 do (d := lcm(lcm(2,3),k); corpus = append(corpus, mk("BP223" | k | "_p" | p, "C5", p, 4, "x^2 + y^2 + z^3 + u^" | k, {d//2, d//2, d//3, d//k}, "3-fold BP", {})));
    for k from 3 to 4 do (d := lcm(6,k); corpus = append(corpus, mk("BP233" | k | "_p" | p, "C5", p, 4, "x^2 + y^3 + z^3 + u^" | k, {d//2, d//3, d//3, d//k}, "3-fold BP", {})));
    corpus = append(corpus, mk("BP3333_p" | p, "C5", p, 4, "x^3 + y^3 + z^3 + u^3", {1,1,1,1}, "3-fold BP", {})));
corpus = append(corpus, mk("dim3mixed_p3", "C5", 3, 4, "x^2 + y^2 + z^3 + z*u^4 + u^6", {3,3,2,1}, "3-fold mixed, mu_3 points, p|w p|d", {}));
corpus = append(corpus, mk("nwf2221_p2", "C5", 2, 4, "x*y + z^2 + z*u^2 + u^4", {2,2,2,1}, "non-well-formed, mu_2 along a divisor of Y, p|r (H5)", {}));
for p in {3,5} do corpus = append(corpus, mk("nwf2221_p" | p, "C5", p, 4, "x^2 + y^2 + z^2 + u^4", {2,2,2,1}, "non-well-formed, mu_2 along a divisor of Y (H5)", {}));
corpus = append(corpus, mk("curvemu3_p3", "C5", 3, 4, "x^2 + y^2 + z^2 + u^6", {3,3,3,1}, "mu_3 along a conic, p|r", {}));

-- ---------------- C6: fourfolds
corpus = append(corpus, mk("dim4mixed_p3", "C6", 3, 5, "x^2 + y^2 + z^2 + u^3 + u*v^4 + v^6", {3,3,3,2,1}, "4-fold mixed, mu_3 along a conic, p|w p|d", {}));
for p in {3,5,7} do for k from 3 to 6 do (d := lcm(2,k); corpus = append(corpus, mk("BP2222" | k | "_p" | p, "C6", p, 5, "x^2 + y^2 + z^2 + u^2 + v^" | k, {d//2, d//2, d//2, d//2, d//k}, "4-fold BP", {})));
corpus = append(corpus, mk("surfmu3_p3", "C6", 3, 5, "x^2 + y^2 + z^2 + u^2 + v^6", {3,3,3,3,1}, "mu_3 along a quadric surface, p|r", {}));

-- ---------------- C10: dimensions 5 and 6 (closes U4 of the existence audit)
for p in {3,5,7} do (
    corpus = append(corpus, mk("BP222223_p" | p, "C10", p, 6, "x^2 + y^2 + z^2 + u^2 + v^2 + s^3", {3,3,3,3,3,2}, "5-fold BP", {}));
    corpus = append(corpus, mk("BP222224_p" | p, "C10", p, 6, "x^2 + y^2 + z^2 + u^2 + v^2 + s^4", {2,2,2,2,2,1}, "5-fold BP", {})));
corpus = append(corpus, mk("dim5mu3_p3", "C10", 3, 6, "x^2 + y^2 + z^2 + u^2 + v^2 + s^6", {3,3,3,3,3,1}, "5-fold, mu_3 along a 3-fold quadric, p|r", {}));
corpus = append(corpus, mk("dim6_p5", "C10", 5, 7, "x^2 + y^2 + z^2 + u^2 + v^2 + s^2 + t^3", {3,3,3,3,3,3,2}, "6-fold BP", {}));
corpus = append(corpus, mk("dim6mu2_p3", "C10", 3, 7, "x^2 + y^2 + z^2 + u^2 + v^2 + s^2 + t^4", {2,2,2,2,2,2,1}, "6-fold, mu_2 along a quadric, p|r", {}));

corpusByName = new HashTable from apply(corpus, s -> s#"name" => s);
familiesOf = fam -> select(corpus, s -> s#"family" == fam);
