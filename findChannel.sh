#!/usr/bin/bash
#
SCANSOURCE="$HOME/bin.local/scanOutputJan.txt"

FIND_CHANNEL=$1

set -o xtrace

grep "$FIND_CHANNEL" "$SCANSOURCE"


