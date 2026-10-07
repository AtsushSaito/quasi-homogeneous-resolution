-- Print the sample library (src/corpus.m2) as TSV: one row per sample, with the definition of the
-- singularity and the literature-based expectations stored in the library.
-- usage: M2 --script scripts/dump_corpus.m2 > corpus.tsv
load(currentFileDirectory | "../src/corpus.m2")
fmt = x -> if x === null then "-" else toString x;
<< "name\tfamily\tp\tn\tf\tw\ttags\texpectArms\texpectCurves\texpectSelf\texpectGenus" << endl;
for s in corpus do (
    << s#"name" << "\t" << s#"family" << "\t" << s#"p" << "\t" << s#"n" << "\t" << s#"f" << "\t" << toString(s#"w")
       << "\t" << s#"tags" << "\t" << fmt(s#"expectArms") << "\t" << fmt(s#"expectCurves") << "\t" << fmt(s#"expectSelf") << "\t" << fmt(s#"expectGenus") << endl);
