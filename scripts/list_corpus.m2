load(currentFileDirectory | "../src/corpus.m2")
fams := select(commandLine, a -> match("^C[0-9]", a));
maxd := 10000; for a in commandLine do if match("^maxd=", a) then maxd = value substring(a, 5);
dOf := s -> (ws := s#"w"; fs := s#"f"; -- weighted degree of the first monomial
    R := QQ[getSymbol "x", getSymbol "y", getSymbol "z", getSymbol "u", getSymbol "v", getSymbol "s", getSymbol "t"]; use R;
    e := first exponents (value fs); sum apply(#ws, i -> ws#i * e#i));
for s in corpus do if (#fams == 0 or member(s#"family", fams)) and dOf s <= maxd then << s#"name" << endl;
