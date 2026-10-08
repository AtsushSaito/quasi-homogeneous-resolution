-- sample.m2 -- global2: build (f, w, p) of a corpus sample, the same way scripts/run_one.m2 does.
--   load this after src/corpus.m2 and src/qh.m2.
--   sampleOf("E8_p2") -> HashTable with "f", "w", "p", "n", "name", "family".
sampleSyms = {getSymbol "x", getSymbol "y", getSymbol "z", getSymbol "u", getSymbol "v", getSymbol "s", getSymbol "t"};
sampleOf = name -> (
    smp := corpusByName#name;
    p := smp#"p"; n := smp#"n";
    R := (ZZ/p)[take(sampleSyms, n)];
    use R;
    new HashTable from {"f" => value smp#"f", "w" => smp#"w", "p" => p, "n" => n, "name" => name, "family" => smp#"family", "R" => R})

-- names of the samples with verdict CONFIRM in the recorded run (361), optionally only n = 3 (302 surfaces)
confirmedNames = (summaryPath, nWanted) -> (
    rows := drop(lines get summaryPath, 1);
    select(apply(rows, ln -> separate("\t", ln)), c -> c#9 == "CONFIRM" and (nWanted == 0 or value c#3 == nWanted)) / (c -> c#0))

-- rows of tests/catalog/hypersurfaces.tsv as HashTables keyed by the column names of the header
catalogRows = tsvPath -> (
    ls := lines get tsvPath;
    hdr := separate("\t", first ls);
    apply(drop(ls, 1), ln -> hashTable apply(pairs separate("\t", ln), pr -> (hdr#(pr#0), pr#1))))

-- the samples a global2 test runs on, chosen by the environment:
--   G2_ONLY=A,B   exactly these names;   G2_SET=confirm   all CONFIRM rows of the catalog (361);
--   G2_SET=surfaces   the CONFIRM rows with n_vars = 3 (302);   default: the CONFIRM rows of tier ci (66).
-- includeSkip: also return the rows with verdict SKIP of the chosen tier (S1 only needs homogeneity there).
g2Rows = (tsvPath, includeSkip) -> (
    rows := catalogRows tsvPath;
    only := getenv "G2_ONLY"; set0 := getenv "G2_SET";
    ok := if only != "" then (r -> member(r#"id", separate(",", only)))
          else if set0 == "confirm" or set0 == "all" then (r -> includeSkip or r#"expected_verdict" == "CONFIRM")
          else if set0 == "surfaces" then (r -> r#"n_vars" == "3" and (includeSkip or r#"expected_verdict" == "CONFIRM"))
          else (r -> r#"tier" == "ci" and (includeSkip or r#"expected_verdict" == "CONFIRM"));
    select(rows, ok))
