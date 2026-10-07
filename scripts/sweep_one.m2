-- One process per reading of Bergh's step A2.  Reads the four ambiguity switches from the
-- environment, runs Algorithm B on a list of cases, and prints one flushed line per case so that
-- a shell timeout still leaves the results obtained so far.  See the A2 ordering sweep (scripts/sweep_a2.sh).
--
-- CASES selects which cases to run and in what order:
--   surfaces  the eleven cyclic quotient surface singularities with r <= 6
--   rank3     the two rank three cones, smaller multiplicity first
--   all       surfaces then rank3 (the default)
-- Put the cheap cases first: a reading that exceeds the limit on an expensive case never reaches
-- anything after it, and a case that is never reached must not be read as a case that failed.
load(currentFileDirectory | "../src/StackyFan.m2");
psiOrder = getenv "PSI_ORDER";
a2Extreme = getenv "A2_EXTREME";
a2Key = getenv "A2_KEY";
a2Interior = (getenv "A2_INTERIOR") == "true";
tag = psiOrder | "/" | a2Extreme | "/" | a2Key | "/" | (getenv "A2_INTERIOR");

-- M2 buffers output, and a shell timeout sends SIGTERM, which discards whatever is still in the
-- buffer.  Open the result file, append one line, and close it again, so every finished case
-- survives even when the process is killed in the middle of the next one.
resultFile = getenv "RESULT_FILE";
say = line -> (
    if resultFile == "" then << line << endl
    else (g := openOutAppend resultFile; g << line << endl; close g));

-- The verdict needs the Hirzebruch-Jung oracle, and that oracle can itself fail (chainSF raises
-- when the resolved fan is not a clean chain).  Guard it separately from algorithmB: an oracle
-- failure is a real disagreement to investigate, and must not be recorded as slowness.
runCase = (nm, F, expect) -> (
    say(tag | " | " | nm | " | RUNNING | - | -");
    t0 := cpuTime();
    ranB := true;
    try algorithmB(F, MaxIter => 20000) else ranB = false;
    dt := cpuTime() - t0;
    if not ranB then (
        say(tag | " | " | nm | " | ALGB-ERROR | - | " | toString dt); return);
    verdict := try (
        nrays := #F#"rays";
        smooth := all(F#"maxCones", c -> multSF(F, c) == 1);
        if not smooth then ("NOTSMOOTH", nrays)
        else if expect === null then ("OK", nrays)
        else (
            ch := minimalizeChain last chainSF F;
            (if ch == expect or ch == reverse expect then "OK" else "MISMATCH " | toString ch,
             nrays))
        ) else null;
    if verdict === null
    then say(tag | " | " | nm | " | ORACLE-ERROR | " | toString(#F#"rays") | " | " | toString dt)
    else say(tag | " | " | nm | " | " | verdict#0 | " | " | toString(verdict#1) | " | " | toString dt);
    );

surfaces = () -> for r from 2 to 6 do for q from 1 to r-1 do (
    if gcd(r,q) != 1 then continue;
    runCase("cyc-"|toString r|"-"|toString q,
            stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}}), hjChainSF(r,q)));

rank3 = () -> (
    runCase("rank3-113", stackyFan({{1,0,0},{0,1,0},{1,1,3}}, {1,1,1}, {{0,1,2}}), null);
    runCase("rank3-125", stackyFan({{1,0,0},{0,1,0},{1,2,5}}, {1,1,1}, {{0,1,2}}), null));

which = getenv "CASES";
if which == "" then which = "all";
-- Parenthesised: in M2 a newline can end a complete expression, so an unbracketed if/else chain
-- broken across lines is a syntax error at the first "else".
(if which == "surfaces" then surfaces()
 else if which == "rank3" then rank3()
 else if which == "all" then (surfaces(); rank3())
 else error("sweep_one: unknown CASES value " | which));
