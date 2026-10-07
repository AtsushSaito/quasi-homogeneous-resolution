-- Catalog runner for hypersurfaces.tsv: weighted-homogeneous isolated hypersurface singularities
-- X = Spec k[x_1..x_n]/(f) over k = F_p.  For each row of the chosen tier the runner
--   (1) re-computes hypothesis (A4) -- X smooth outside the vertex -- with a plain Jacobian computation
--       (dim of k[x]/(f, partial f) is 0; the same formula as in qhReport, here as a cross-check of the table);
--   (2) runs qhVerify(f, w) (src/qh.m2: prediction from the stabiliser strata, explicit toric
--       resolution of the weighted blow-up, comparison) and compares verdict, stabiliser orders,
--       number of exceptional curves, lengths of the arms, central self-intersection and genus with
--       the columns expected_* of the table.
--   M2 --script tests/catalog/run_hypersurfaces.m2                  # tier ci  (about 2-3 minutes)
--   TIER=all M2 --script tests/catalog/run_hypersurfaces.m2         # all 440 rows (about 25 minutes)
--   ONLY=E8_p2,D4_p3 M2 --script tests/catalog/run_hypersurfaces.m2   # selected ids
load(currentFileDirectory | "../../src/qh.m2")
tier = getenv "TIER"; if tier == "" then tier = "ci";
only = getenv "ONLY"; onlyList = if only == "" then {} else separate(",", only);
rows = drop(lines get(currentFileDirectory | "hypersurfaces.tsv"), 1);
col = {"id"=>0,"category"=>1,"p"=>2,"n_vars"=>3,"equation"=>4,"weights"=>5,"degree"=>6,"features"=>7,
       "verdict"=>8,"strata"=>9,"curves"=>10,"arms"=>11,"self"=>12,"genus"=>13,"evidence"=>14,"tier"=>17};
colH = hashTable col;
syms = {getSymbol "x", getSymbol "y", getSymbol "z", getSymbol "u", getSymbol "v", getSymbol "s", getSymbol "t"};
asList = s -> if s == "-" then null else value s;
nPass = 0; nFail = 0; nSkipRows = 0; t00 = currentTime();
for ln in rows do (
    c := separate("\t", ln);
    id := c#0;
    if #onlyList > 0 and not member(id, onlyList) then continue;
    if #onlyList == 0 and tier != "all" and c#(colH#"tier") != "ci" then continue;
    p := value c#2; n := value c#3; w := value c#5;
    kk := ZZ/p;
    R := kk[take(syms, n)]; use R;
    f := value c#4;
    problems := {};
    -- (1) re-computation of (A4)
    a4 := dim(R/(ideal f + ideal jacobian f)) == 0;
    expVerdict := c#(colH#"verdict");
    if a4 != (expVerdict != "SKIP") then problems = append(problems, "A4 by Jacobian is " | toString a4);
    -- (2) the main computation
    t0 := currentTime();
    r := qhVerify(f, w);
    secs := currentTime() - t0;
    v := r#"verdict";
    if v != expVerdict then problems = append(problems, "verdict " | v | " (expected " | expVerdict | ")")
    else if v != "SKIP" then (
        rep := r#"report"; pr := r#"predict"; r2 := r#"L2";
        eStrata := asList c#(colH#"strata");
        if eStrata =!= null and apply(rep#"strata", st -> st#"r") != eStrata
        then problems = append(problems, "strata orders " | toString apply(rep#"strata", st -> st#"r") | " (expected " | toString eStrata | ")");
        eCurves := asList c#(colH#"curves");
        if eCurves =!= null then (
            if not r2#?"N" or r2#"N" != eCurves then problems = append(problems, "number of curves");
            eArms := asList c#(colH#"arms");
            if not r2#?"arms" or sort apply(r2#"arms", a -> #(a#1)) != eArms then problems = append(problems, "arms");
            eSelf := asList c#(colH#"self");
            if r2#"centreSelf" != eSelf then problems = append(problems, "centre self-intersection");
            eGenus := asList c#(colH#"genus");
            if pr#"genusY" != eGenus then problems = append(problems, "genus");
            if r2#"negdef" =!= true then problems = append(problems, "intersection form not negative definite")));
    if #problems == 0 then nPass = nPass + 1 else (
        nFail = nFail + 1;
        << "FAIL " << id << ": " << concatenate between("; ", problems) << endl);
    << "  " << id << "  " << v << "  " << secs << " s" << endl);
<< "hypersurface catalog (tier " << tier << "): " << nPass << " passed, " << nFail << " failed, "
   << currentTime() - t00 << " s" << endl;
if nFail > 0 then exit 1;
