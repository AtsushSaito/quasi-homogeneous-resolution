# Shared by run_ci.sh and run_all.sh.  POSIX sh.
# step "<label>" command args...   runs the command, hides its output unless it fails,
# prints PASS/FAIL with the elapsed seconds, and counts failures in $FAILED.
FAILED=0
PASSED=0
LOGDIR=$(mktemp -d)
trap 'rm -rf "$LOGDIR"' EXIT
step() {
    label=$1; shift
    log="$LOGDIR/$(echo "$label" | tr -c 'A-Za-z0-9' '_').log"
    start=$(date +%s)
    if "$@" > "$log" 2>&1; then
        printf 'PASS  %-58s %4ss\n' "$label" "$(( $(date +%s) - start ))"
        PASSED=$((PASSED + 1))
        # one-line summary printed by the runner itself, if there is one
        grep -E '(passed|OK|consistency|ok)' "$log" | grep -Ev 'INSTALL|^ --' | tail -1 | sed 's/^/        /' | cut -c1-150
    else
        printf 'FAIL  %-58s %4ss\n' "$label" "$(( $(date +%s) - start ))"
        FAILED=$((FAILED + 1))
        grep -E 'FAIL|error|assert' "$log" | head -15 | sed 's/^/        /' | cut -c1-200
    fi
}
finish() {
    echo "----"
    echo "$PASSED step(s) passed, $FAILED failed"
    [ "$FAILED" -eq 0 ]
}
