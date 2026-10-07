#!/bin/sh
# Everything in run_ci.sh plus the heavy tiers: all 440 hypersurface rows, cyclic quotients up to r = 16,
# the rank-3 cone of multiplicity 5, and all examples.  About 40 minutes.   Usage: sh tests/run_all.sh
# (The 16 readings of Bergh's step A2 are separate: CASES=rank3 sh scripts/sweep_a2.sh, up to an hour.)
cd "$(dirname "$0")/.." || exit 2
. tests/lib.sh
command -v M2 > /dev/null || { echo "M2 not found on PATH"; exit 2; }

step "run_ci.sh"                                               sh tests/run_ci.sh
step "catalog: cyclic quotients, all rows (r<=16)"             env TIER=all M2 --script tests/catalog/run_cyclic.m2
step "catalog: simplicial cones, all rows"                     env TIER=all M2 --script tests/catalog/run_fans.m2
step "catalog: hypersurfaces, all 440 rows"                    env TIER=all M2 --script tests/catalog/run_hypersurfaces.m2
for f in examples/*.m2; do
    step "example $f"                                           M2 --script "$f"
done
finish
