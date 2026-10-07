load(currentFileDirectory | "../src/StackyFan.m2")
cone3 = v -> stackyFan({{1,0,0},{0,1,0},v}, {1,1,1}, {{0,1,2}});
hard = {{1,2,5},{1,2,7}};
results = {};
for po in {"first","last"} do for ae in {"max","min"} do for ak in {"nd-mult","mult-nd"} do for ai in {true,false} do (
    psiOrder = po; a2Extreme = ae; a2Key = ak; a2Interior = ai;
    okAll := true; detail := {};
    for v in hard do (
        F := cone3 v;
        alarm 15;
        ok := try (algorithmB F; isSmoothSF F) else false;
        alarm 0;
        detail = append(detail, if ok then #F#"rays" else -1);
        if not ok then okAll = false);
    << po << " / " << ae << " / " << ak << " / interior=" << ai << "  ->  " << detail
       << (if okAll then "   *** BOTH TERMINATE ***" else "") << endl;
    if okAll then results = append(results, {po, ae, ak, ai}));
<< endl << "combinations that terminate on both: " << results << endl;
