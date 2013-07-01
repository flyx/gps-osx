#!/bin/bash

. `dirname $0`/../../scripts/CONFIG.sh

print_header "Common"
parse_opts "$@"

if [ "$clean" = 1 ]; then
   # ??? What should we do here ?
   echo ""
   exit 0
fi

run_and_exit "gprbuild -q -gnat05 -ws -P../common test_htables.adb test_arrays.adb test_trie.adb test_strings.adb $EXTRA_GPRBUILD_OPT"
$valgrind ../obj/$OBJ_SUBDIR/test_htables
$valgrind ../obj/$OBJ_SUBDIR/test_arrays
$valgrind ../obj/$OBJ_SUBDIR/test_trie
$valgrind ../obj/$OBJ_SUBDIR/test_strings

echo_with_status 1 ""
