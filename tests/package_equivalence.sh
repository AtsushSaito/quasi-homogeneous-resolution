#!/bin/sh
# The package in package/ and the research library StackyFan.m2 both define stackyFan as a global,
# so they cannot be loaded into one process.  Run each in its own process and compare the output.
set -e
cd "$(dirname "$0")/.."
out=$(mktemp -d)
trap 'rm -rf "$out"' EXIT
M2 --script tests/dump_package.m2  > "$out/pkg.txt"
M2 --script tests/dump_research.m2 > "$out/res.txt"
if diff -u "$out/res.txt" "$out/pkg.txt"; then
    echo "PACKAGE EQUIVALENCE OK ($(wc -l < "$out/pkg.txt" | tr -d ' ') cases)"
else
    echo "PACKAGE EQUIVALENCE FAILED"
    exit 1
fi
