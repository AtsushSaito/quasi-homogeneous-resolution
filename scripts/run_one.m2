-- run one corpus sample: M2 --script run_one.m2 -- <name>
load(currentFileDirectory | "../src/corpus.m2")
load(currentFileDirectory | "../src/qh.m2")
name = last commandLine;
smp = corpusByName#name;
p = smp#"p"; n = smp#"n";
kk = ZZ/p;
varNames = take({getSymbol "x", getSymbol "y", getSymbol "z", getSymbol "u", getSymbol "v", getSymbol "s", getSymbol "t"}, n);
R = kk[varNames];
use R;
f = value smp#"f";
w = smp#"w";
<< "sample " << name << "  family " << smp#"family" << "  tags: " << smp#"tags" << endl;
t0 = currentTime();
alarm 900;
result0 = qhVerify(f, w);
alarm 0;
secs = currentTime() - t0;
fmt = x -> if x === null then "-" else toString x;
v = result0#"verdict";
if v == "SKIP" then (
    << "RESULT\t" << name << "\t" << smp#"family" << "\t" << p << "\t" << n << "\t-\t" << smp#"tags" << "\tfalse\t-\t-\tSKIP\t-\t-\t-\t-\t-\t-\t-\t" << secs << "\t-\t-" << endl;
    exit 0);
rep = result0#"report"; pr = result0#"predict"; r2 = result0#"L2";
strata = apply(rep#"strata", st -> st#"r");
nObs = if r2#?"N" then r2#"N" else null;
armsObs = if r2#?"arms" then sort apply(r2#"arms", a -> #(a#1)) else null;
armsPred = if pr#?"arms" then sort flatten apply(pr#"arms", a -> toList(a#0 : #(a#1))) else null;
selfObs = if r2#?"arms" then flatten apply(r2#"arms", a -> a#1) else {};
ext = "-";
if smp#"expectArms" =!= null and r2#?"arms" then (
    okA = (armsObs == sort smp#"expectArms");
    okN = (nObs == smp#"expectCurves");
    expSelf = smp#"expectSelf";
    okS = if #expSelf == 1 then (r2#"centreSelf" == -(expSelf#0) and #selfObs == 0) else (r2#"centreSelf" == -2 and all(selfObs, b -> b == 2));
    okG = (pr#"genusY" == smp#"expectGenus");
    ext = if okA and okN and okS and okG then "EXT-MATCH" else ("EXT-MISMATCH(" | (if okA then "" else "arms ") | (if okN then "" else "count ") | (if okS then "" else "self ") | (if okG then "" else "genus") | ")"));
<< "RESULT\t" << name << "\t" << smp#"family" << "\t" << p << "\t" << n << "\t" << rep#"d" << "\t" << smp#"tags"
   << "\t" << rep#"A4" << "\t" << rep#"nondegenerate" << "\t" << toString strata << "\t" << v
   << "\t" << fmt nObs << "\t" << fmt (if pr#?"nCurves" then pr#"nCurves" else null) << "\t" << fmt armsObs << "\t" << fmt armsPred
   << "\t" << fmt (if r2#?"centreSelf" then r2#"centreSelf" else null) << "\t" << fmt (if pr#?"genusY" then pr#"genusY" else null)
   << "\t" << fmt (if r2#?"negdef" then r2#"negdef" else null) << "\t" << secs << "\t" << ext << "\t" << concatenate between("; ", result0#"notes") << endl;
