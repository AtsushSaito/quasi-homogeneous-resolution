-- certify.m2 -- emit a certificate, checked by direct computation (no resolution theorem is used), that X = Spec R has a global resolution.
-- usage: M2 --script certify.m2 -- <corpus name> [<corpus name> ...]
load(currentFileDirectory | "corpus.m2")
load(currentFileDirectory | "qh.m2")
certifyResolution = (nm, p, n, f, w) -> (
    R := ring f;
    L := {};
    add := t -> L = append(L, t);
    add("X = Spec F_" | toString p | "[" | toString(gens R) | "]/(" | toString f | "),  weights " | toString w | ",  dim X = " | toString(n-1));
    J := ideal f + ideal jacobian f;
    a4 := dim J <= 0;
    add("(0) A4  X is smooth over k away from the vertex: dim V(f, df) = " | toString dim J | "  ->  " | toString a4);
    if not a4 then return (false, L);
    T := makeSmooth toricBlowup(toList(0..n-1), affineSpace n, w);
    rayList := rays T; coneList := max T;
    sm := all(coneList, c -> abs det matrix rayList_c == 1);
    add("(1) T is a smooth toric variety: " | toString(#rayList) | " rays, " | toString(#coneList) | " maximal cones, all determinants +-1 -> " | toString sm);
    (dir | nm | ".fan.txt") << toString rayList << endl << toString coneList << endl << close;
    (pr, prNotes) := refinesOrthantExact(rayList, coneList);
    add("(2) T -> A^n is proper: the fan refines the orthant (exact combinatorial test) -> " | toString pr);
    for t in prNotes do add("      " | t);
    basisVecs := entries id_(ZZ^n);
    added := select(rayList, r -> not member(r, basisVecs));
    iso := all(added, r -> all(r, c -> c > 0));
    add("(3) T -> A^n is an isomorphism off the origin: added rays " | toString added | " all interior -> " | toString iso);
    kk := coefficientRing R;
    Y := kk[apply(n, j -> (getSymbol "yy")_j)];
    nbad := 0; exc := {}; cofs := {};
    for sigma in coneList do (
        V := rayList_sigma;
        g := sub(f, matrix{ apply(n, i -> product(n, j -> Y_j^(V#j#i))) });
        e := exponents g;
        ft := g // product(n, j -> Y_j^(min apply(e, t -> t#j)));
        Ich := ideal ft + ideal jacobian ft;
        if dim Ich >= 0 then nbad = nbad + 1
        else (cc := unitCertificate Ich;
              if cc === null then nbad = nbad + 1
              else cofs = append(cofs, (sigma, "smoothness", Ich, cc)));
        for a from 0 to n-1 do if all(V#a, c -> c > 0) and dim(ideal ft + ideal Y_a) >= 0 then exc = append(exc, sigma#a));
    smx := (nbad == 0);
    add("(4) the strict transform X~ is smooth in every chart: " | toString(#coneList) | " charts, " | toString nbad | " singular -> " | toString smx);
    add("    exceptional divisors meeting X~: " | toString(#unique exc));
    -- (5) STRONG resolution: is the exceptional locus a simple normal crossings divisor on X~?
    -- The toric boundary of the smooth T is SNC, so it restricts to an SNC divisor on X~ exactly
    -- when X~ meets every toric stratum transversally.  In a chart that says: for every subset S
    -- of the exceptional coordinates, ft restricted to y_S = 0 is either a unit or defines a
    -- smooth hypersurface in the remaining variables.
    nsnc := 0; ncontained := 0;
    for sigma in coneList do (
        V := rayList_sigma;
        g0 := sub(f, matrix{ apply(n, i -> product(n, j -> Y_j^(V#j#i))) });
        e0 := exponents g0;
        ft := g0 // product(n, j -> Y_j^(min apply(e0, t -> t#j)));
        excHere := select(toList(0..n-1), a -> all(V#a, c -> c > 0));
        for S in subsets excHere do (
            if #S == 0 then continue;
            g := sub(ft, apply(S, a -> Y_a => 0_Y));
            if g == 0 then (ncontained = ncontained + 1; continue);
            rest := select(toList(0..n-1), j -> not member(j, S));
            JJ := ideal g + ideal apply(rest, j -> diff(Y_j, g));
            if JJ != ideal 1_Y then nsnc = nsnc + 1
            else (cc2 := unitCertificate JJ;
                  if cc2 === null then nsnc = nsnc + 1
                  else cofs = append(cofs, (sigma, "snc " | toString S, JJ, cc2)))));
    snc := (nsnc == 0 and ncontained == 0);
    add("(5) the exceptional locus is a simple normal crossings divisor on X~: X~ meets every toric");
    add("    stratum transversally -- non-transverse strata " | toString nsnc | ", strata contained in X~ "
        | toString ncontained | " -> " | toString snc);
    add("(6) every smoothness and SNC claim above comes with an explicit unit-ideal certificate:");
    add("    " | toString(#cofs) | " identities of the form  sum_i g_i h_i = 1,  verified by expansion");
    ok := a4 and sm and pr and iso and smx and snc and (#cofs > 0);
    cofFile := dir | nm | ".cofactors.txt";
    cofFile << "Unit-ideal certificates for " << nm << endl
            << "characteristic " << p << endl
            << "Each block lists generators h_i and cofactors g_i with sum_i g_i h_i = 1." << endl;
    for t in cofs do cofFile << endl << "cone " << t#0 << "  [" << t#1 << "]" << endl
        << "  h = " << toString flatten entries gens t#2 << endl
        << "  g = " << toString flatten entries transpose t#3 << endl;
    cofFile << close;
    add("VERDICT: " | (if ok then "X~ -> X is a resolution of singularities in the STRONG classical sense: X~ smooth, the map proper and birational, an isomorphism over X minus the vertex, and the exceptional locus a simple normal crossings divisor. No resolution theorem was cited; the one result used is the properness criterion for toric morphisms (Cox-Little-Schenck, Theorem 3.4.11), applied through check (2)."
                       else "NOT CERTIFIED"));
    (ok, L));
-- A mistyped sample name used to be dropped in silence: no certificate, no message, exit 0.
args = select(drop(commandLine, 1), a -> not match("^-", a) and not match("\\.m2$", a));
unknown = select(args, a -> not corpusByName#?a);
if #unknown > 0 then error("certify: no corpus sample named " | concatenate between(", ", unknown));
names = select(args, a -> corpusByName#?a);
dir = currentFileDirectory | "../data/certificates/";
makeDirectory dir;
for nm in names do (
    smp := corpusByName#nm;
    p := smp#"p"; n := smp#"n";
    -- take truncates in silence, so an n larger than the symbol list would build a ring with too
    -- few variables and fail later with an unrelated error.  The corpus already reaches n = 7.
    syms := {getSymbol "x", getSymbol "y", getSymbol "z", getSymbol "u", getSymbol "v", getSymbol "s", getSymbol "t"};
    if n > #syms then error("certify: " | nm | " needs " | toString n | " variables but only "
        | toString(#syms) | " symbols are defined");
    R := (ZZ/p)[take(syms, n)];
    use R; f := value smp#"f";
    (ok, L) := certifyResolution(nm, p, n, f, smp#"w");
    dir | nm | ".txt" << concatenate between("\n", L) << endl << close;
    << nm << " : " << (if ok then "CERTIFIED" else "NOT CERTIFIED") << endl);
