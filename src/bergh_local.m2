-- Route 2 (stacky): resolve the coarse space of the smooth tame quotient stack [(X \ {v}) x A^1 / G_m]
-- by running Bergh's Algorithm B on the local model [A^{n-1}/mu_r] at each stabiliser stratum.  This
-- uses only that the stack is smooth and tame with mu_r stabilisers (see docs/MATH.md, steps 1-3)
-- and Bergh, Thm 1.2.  It does NOT use the toric embedded resolution of the ambient space (route 1,
-- src/qh.m2), so it does not depend on Newton non-degeneracy.
load(currentFileDirectory | "qh.m2")
load(currentFileDirectory | "StackyFan.m2")

berghArms = (f, w) -> (
    rep := qhReport(f, w);
    pr := qhPredict(f, w, rep);
    out := {};
    for st in pr#"strata" do (
        r := st#"r"; tw := st#"weights"; dg := st#"deg";
        if dg < 0 then (out = append(out, ("positive-dimensional", r, tw)); continue);
        G := basicToricStackyFan(r, tw);
        algorithmB G;
        if not isSmoothSF G then error "berghArms: Algorithm B did not make the coarse space smooth";
        (path, interior, bs) := chainSF G;
        mn := minimalizeChain bs;
        predChain := if st#?"chain" then st#"chain" else null;
        << "  stratum mu_" << r << " weights " << tw << " deg " << dg
           << " :  Bergh " << bs << " -> minimal " << mn
           << (if predChain =!= null then ("   predicted (HJ) " | toString predChain) else "") << endl;
        for k from 1 to dg do out = append(out, mn));
    sort apply(out, a -> if class a === List then #a else a));
