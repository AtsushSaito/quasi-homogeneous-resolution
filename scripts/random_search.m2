-- C9: random search for quasi-homogeneous f (n = 3) with A4 but Newton-degenerate or non-convenient.
-- usage: M2 --script random_search.m2 -- p=2 seed=1 samples=20 wmax=6
load(currentFileDirectory | "../src/qh.m2")
opt = new MutableHashTable from {"p" => 2, "seed" => 1, "samples" => 20, "wmax" => 6, "dmax" => 18};
for a in commandLine do if match("=", a) then (k := (separate("=", a))#0; opt#k = value (separate("=", a))#1);
p = opt#"p"; setRandomSeed opt#"seed";
kk = ZZ/p; R = kk[x,y,z];
found = {}; tried = 0; a4count = 0;
weightsList = {};
for w1 from 1 to opt#"wmax" do for w2 from w1 to opt#"wmax" do for w3 from w2 to opt#"wmax" do if gcd(gcd(w1,w2),w3) == 1 then weightsList = append(weightsList, {w1,w2,w3});
for w in weightsList do for d from 2*(max w) to opt#"dmax" do (
    Rw := kk[x,y,z, Degrees => w];
    mons := flatten entries basis(d, Rw);
    if #mons < 3 then continue;
    for s from 1 to opt#"samples" do (
        f := sub(sum apply(mons, m -> (random kk) * m), R);
        if f == 0 then continue;
        tried = tried + 1;
        J := ideal f + ideal jacobian f;
        if dim J > 0 then continue;
        a4count = a4count + 1;
        lf := listForm f;
        conv := all(3, i -> any(lf, pr -> (e := pr#0; e#i > 0 and all(3, j -> j == i or e#j == 0))));
        nondeg := true;
        for Jset in subsets({0,1,2}) do (
            if #Jset == 3 then continue;
            fJ := sub(f, apply(Jset, j -> R_j => 0));
            if fJ == 0 then continue;
            comp := select({0,1,2}, i -> not member(i, Jset));
            IJ := ideal fJ + ideal apply(comp, i -> diff(R_i, fJ));
            if saturate(IJ, product apply(comp, i -> R_i)) != ideal 1_R then nondeg = false);
        if conv and nondeg then continue;
        found = append(found, (f, w, d, conv, nondeg))));
<< "p = " << p << ": tried " << tried << ", A4 = " << a4count << ", A4 & (non-convenient or degenerate) = " << #found << endl;
-- run L2 on the candidates
for c in found do (
    (f, w, d, conv, nondeg) := c;
    << endl << "######## candidate f = " << toString f << "  w = " << w << "  d = " << d << "  convenient " << conv << "  nondegenerate " << nondeg << endl;
    r := try qhVerify(f, w) else null;
    if r === null then << "C9RESULT\t" << p << "\t" << toString f << "\t" << toString w << "\t" << d << "\t" << conv << "\t" << nondeg << "\tERROR\t" << endl
    else << "C9RESULT\t" << p << "\t" << toString f << "\t" << toString w << "\t" << d << "\t" << conv << "\t" << nondeg << "\t" << r#"verdict" << "\t" << concatenate between("; ", r#"notes") << endl);
