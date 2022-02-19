#!/bin/bash

# BEGIN: Read functions from helper_functions.
MNK_HELPER_FUNCTIONS="helper_functions"
if [[ ! -f "${MNK_HELPER_FUNCTIONS}" ]]; then
  echo "Required file does not exist: ${MNK_HELPER_FUNCTIONS}"
  exit 1
fi
. "${MNK_HELPER_FUNCTIONS}"

# END: Read functions from helper_functions.

mnk_initialize

echo "testing our functions"
mnk_echo "Color yellow" yellow

mnk_echo "Color manu is awesome red" white

mnk_echo "Color magenta" magenta

mnk_echo "Color blue" blue

mnk_echo "Color unknown" dkdkkd