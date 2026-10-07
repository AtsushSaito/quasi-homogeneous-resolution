#!/bin/sh
# Verify the submittable package the way a Macaulay2 package reviewer would: installPackage must build the
# documentation and run every example, and check must pass every TEST block.  Both run in one
# process, into a throwaway prefix so nothing is written to your Macaulay2 installation --
# or, as happened once, into a directory named after a stray command-line flag in the repo root.
set -e
cd "$(dirname "$0")/.."
prefix=$(mktemp -d)
script=$(mktemp)
trap 'rm -rf "$prefix" "$script"' EXIT
cat > "$script" <<'M2'
-- The prefix arrives in the environment.  Reading it out of commandLine is not worth the risk:
-- under "M2 --script f.m2 arg" the flag itself is still in that list.
prefix = getenv "M2_INSTALL_PREFIX";
if prefix == "" then error "package_check: M2_INSTALL_PREFIX is not set";
path = prepend("./package/", path);
installPackage("ToricDestackification",
    RerunExamples => true, IgnoreExampleErrors => false,
    InstallPrefix => prefix | "/");
print "INSTALL OK";
check "ToricDestackification";
print "CHECK OK";
M2
log=$(mktemp)
trap 'rm -rf "$prefix" "$script" "$log"' EXIT
rc=0
M2_INSTALL_PREFIX="$prefix" M2 --script "$script" > "$log" 2>&1 || rc=$?
grep -Ev '^ -- capturing (example results|check)' "$log" || true
# the exit status of M2 and both markers must be present, otherwise the check did not run to the end
if [ "$rc" -ne 0 ] || ! grep -q '^INSTALL OK' "$log" || ! grep -q '^CHECK OK' "$log"; then
    echo "PACKAGE CHECK FAILED (M2 exit status $rc)"
    exit 1
fi
