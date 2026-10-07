path = prepend(currentFileDirectory | "../package/", path);
loadPackage("ToricDestackification", Reload => true);
dump = (nm, F) -> (
    destackify F;
    << nm << " | rays " << stackyRays F << " | labels " << stackyLabels F
       << " | cones " << sort maximalCones F << endl);
for r from 2 to 8 do for q from 1 to r-1 do (
    if gcd(r,q) != 1 then continue;
    dump("cone-"|toString r|"-"|toString q, stackyFan({{0,1},{r,-q}}, {1,1}, {{0,1}})));
for r from 2 to 6 do for q from 1 to r-1 do (
    if gcd(r,q) != 1 then continue;
    dump("basic-"|toString r|"-"|toString q, basicToricStackyFan(r, {1,q})));
dump("rank3-125", stackyFan({{1,0,0},{0,1,0},{1,2,5}}, {1,1,1}, {{0,1,2}}));
dump("rank3-113", stackyFan({{1,0,0},{0,1,0},{1,1,3}}, {1,1,1}, {{0,1,2}}));
dump("label-3", stackyFan({{0,1},{5,-2}}, {3,1}, {{0,1}}));
dump("rank3-112", stackyFan({{1,0,0},{0,1,0},{1,1,2}}, {1,1,1}, {{0,1,2}}));
dump("rank3-123", stackyFan({{1,0,0},{0,1,0},{1,2,3}}, {1,1,1}, {{0,1,2}}));
dump("rank3-114", stackyFan({{1,0,0},{0,1,0},{1,1,4}}, {1,1,1}, {{0,1,2}}));
dump("rank3-124", stackyFan({{1,0,0},{0,1,0},{1,2,4}}, {1,1,1}, {{0,1,2}}));
dump("rank3-115", stackyFan({{1,0,0},{0,1,0},{1,1,5}}, {1,1,1}, {{0,1,2}}));
dump("rank4-1112", stackyFan({{1,0,0,0},{0,1,0,0},{0,0,1,0},{1,1,1,2}}, {1,1,1,1}, {{0,1,2,3}}));
dump("rank4-1113", stackyFan({{1,0,0,0},{0,1,0,0},{0,0,1,0},{1,1,1,3}}, {1,1,1,1}, {{0,1,2,3}}));
dump("label-2-3", stackyFan({{1,0},{0,1}}, {2,3}, {{0,1}}));
dump("smooth", stackyFan({{1,0,0},{0,1,0},{0,0,1}}, {1,1,1}, {{0,1,2}}));
