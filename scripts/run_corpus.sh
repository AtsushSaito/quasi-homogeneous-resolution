#!/bin/sh
# POSIX sh, not zsh: zsh does not word-split an unquoted parameter expansion, so "for name in
# $wanted" would run the loop once with the whole newline-separated list as a single name.  That
# is exactly what happened when the completeness check below was first added.
# usage: scripts/run_corpus.sh C1 [C4 ...]   -> results/<name>.txt and "$SUMMARY"
cd "$(dirname "$0")/.."
# SUMMARY: table to append to.  The default is the recorded run; names already present are skipped, so with the
# shipped file nothing is recomputed.  To re-run from scratch: SUMMARY=results/rerun.tsv scripts/run_corpus.sh
SUMMARY=${SUMMARY:-results/summary.tsv}
mkdir -p results
if [ ! -f "$SUMMARY" ]; then
  printf 'name\tfamily\tp\tn\td\ttags\tA4\tnondeg\tstrata\tverdict\tnCurvesObs\tnCurvesPred\tarmsObs\tarmsPred\tcentreSelf\tgenusPred\tnegdef\tseconds\text\tnotes\n' > "$SUMMARY"
fi
# Capture the list once, so the completeness check below compares against the same set the loop
# walked.  The loop skips names already present, which is what makes a truncated earlier run
# invisible: the gap is never revisited and the row count silently understates the corpus.
wanted=$(M2 --script scripts/list_corpus.m2 -- "$@")
for name in $wanted; do
  if grep -q "^$name	" "$SUMMARY"; then continue; fi
  M2 --script scripts/run_one.m2 -- "$name" > "results/$name.txt" 2>&1
  line=$(grep '^RESULT' "results/$name.txt" | head -1 | cut -f2-)
  if [ -z "$line" ]; then line="$name	?	?	?	?	?	?	?	?	CRASH	-	-	-	-	-	-	-	-	-	$(grep -m1 'error' "results/$name.txt" | head -c 120)"; fi
  echo "$line" >> "$SUMMARY"
  echo "$line" | cut -f1,10,11,12,13,14,15,19 | tr '\t' ' '
done

missing=0
for name in $wanted; do
  if ! grep -q "^$name	" "$SUMMARY"; then
    echo "MISSING: $name" >&2
    missing=$((missing + 1))
  fi
done
have=$(echo "$wanted" | wc -w | tr -d ' ')
echo "corpus: $((have - missing))/$have rows present in $SUMMARY"
if [ "$missing" -gt 0 ]; then
  echo "$missing sample(s) produced no row; the summary is incomplete" >&2
  exit 1
fi
