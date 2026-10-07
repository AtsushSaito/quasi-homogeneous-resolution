-- Catalog runner for cyclic.tsv: Bergh's Algorithm B (package ToricDestackification) on the cone
-- spanned by (0,1) and (r,-q), i.e. the cyclic quotient singularity 1/r(1,q), compared with the
-- Hirzebruch-Jung continued fraction r/q tabulated by gen_cyclic.py (independent Python code).
--   M2 --script tests/catalog/run_cyclic.m2            # tier ci  (r <= 12)
--   TIER=all M2 --script tests/catalog/run_cyclic.m2   # everything in the table (r <= 16)
path = prepend(currentFileDirectory | "../../package/", path);
needsPackage "ToricDestackification";
tier = getenv "TIER"; if tier == "" then tier = "ci";
rows = drop(lines get(currentFileDirectory | "cyclic.tsv"), 1);
nPass = 0; nFail = 0; t0 = currentTime();
for ln in rows do (
    c := separate("\t", ln);
    id := c#0; r := value c#1; q := value c#2; expected := value c#3; nExp := value c#4;
    if tier != "all" and c#5 != "ci" then continue;
    F := stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}});
    mult := coneMultiplicity(F, {0,1});
    destackify F;
    smooth := isSmoothStackyFan F;
    chain := contractMinusOneCurves resolutionChain F;
    ok := (mult == r) and smooth and chain == expected and #chain == nExp
          and chain == hirzebruchJung(r, q);
    if ok then nPass = nPass + 1 else (
        nFail = nFail + 1;
        << "FAIL " << id << ": multiplicity " << mult << ", smooth " << smooth << ", chain " << chain
           << ", expected " << expected << endl));
<< "cyclic catalog (tier " << tier << "): " << nPass << " passed, " << nFail << " failed, "
   << currentTime() - t0 << " s" << endl;
if nFail > 0 then exit 1;
