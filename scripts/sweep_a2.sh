#!/bin/sh
# Bergh's step A2 leaves four things unspecified (see the Caveat in package/ToricDestackification.m2).  Run each of the sixteen readings in
# its own process under a shell timeout, so that a reading which diverges kills only itself and
# the lines already printed survive.  The earlier attempt ran all sixteen in one process with
# M2's alarm, which does not interrupt a running computation, and produced nothing.
#
#   LIMIT   seconds per reading (default 200, the limit the recorded evidence was produced under)
#   CASES   surfaces | rank3 | all   (passed through to scripts/sweep_one.m2)
#   OUT     output directory (default results/sweep_a2, or results/sweep_a2_<CASES>)
set -e
cd "$(dirname "$0")/.."
LIMIT=${LIMIT:-200}
CASES=${CASES:-all}
if [ "$CASES" = all ]; then OUT=${OUT:-results/sweep_a2}; else OUT=${OUT:-results/sweep_a2_$CASES}; fi
mkdir -p "$OUT"

# The limit and the case list decide which readings appear to terminate, so record them next to
# the data.  A results directory that does not say what limit produced it cannot be interpreted.
printf '# sweep of Bergh A2 readings\n# limit %s s per reading, CASES=%s, %s\n' \
    "$LIMIT" "$CASES" "$(date -u '+%Y-%m-%dT%H:%M:%SZ')" > "$OUT/RUN.txt"

results=$(mktemp)
trap 'rm -f "$results"' EXIT
failed=0

for po in first last; do
for ex in max min; do
for ky in nd-mult mult-nd; do
for it in true false; do
    name="$po-$ex-$ky-$it"
    tag="$po/$ex/$ky/$it"
    f="$OUT/$name.txt"
    printf '%s ... ' "$name"
    : > "$f"
    set +e
    PSI_ORDER=$po A2_EXTREME=$ex A2_KEY=$ky A2_INTERIOR=$it CASES=$CASES RESULT_FILE="$f" \
        timeout "$LIMIT" M2 --script scripts/sweep_one.m2 > "$f.log" 2>&1
    rc=$?
    set -e
    # timeout(1) returns 124 only when it fired.  Any other nonzero status is the runner itself
    # failing -- a parse error, a missing file, an M2 crash -- and must not be recorded as
    # slowness, or a broken runner looks exactly like a reading that diverges.
    # The tag is slash-joined to match what the M2 side writes; the dash-joined directory name
    # cannot be parsed back into the four switches, because nd-mult contains a dash itself.
    if [ "$rc" = 0 ]; then
        verb=done
    elif [ "$rc" = 124 ]; then
        verb="cut off at ${LIMIT}s"
        echo "$tag | -- | TIMEOUT | - | -" >> "$f"
    else
        verb="RUNNER FAILED (status $rc, see $f.log)"
        echo "$tag | -- | RUNNER-ERROR | - | -" >> "$f"
        failed=$((failed + 1))
    fi
    # RUNNING lines are progress markers, not results; count only the results.
    printf '%s (%s cases finished)\n' "$verb" "$(awk -F' \\| ' '$3 != "RUNNING"' "$f" | wc -l | tr -d ' ')"
done; done; done; done

# Aggregate through a file outside OUT.  "cat $OUT/*.txt > $OUT/all.txt" would include all.txt in
# its own glob: the shell truncates it first, then BSD cat reads the file it is writing and copies
# its own output forever, filling the disk.  GNU cat refuses; macOS cat does not.
cat "$OUT"/*.txt > "$results"
mv "$results" "$OUT/all.txt"
trap - EXIT
echo "wrote $OUT/all.txt"
if [ "$failed" -gt 0 ]; then
    echo "$failed reading(s) failed to run at all; the sweep is not interpretable" >&2
    exit 1
fi
