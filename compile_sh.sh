#!/bin/bash
set -e
cd "$( dirname "$0" )"

SCRIPT_FILE="$1"
FILENAME="$( basename "$SCRIPT_FILE" )"
OUTPUT="dist/${FILENAME}"

# LC_ALL=C.UTF-8 to avoid shellcheck issue #324
LC_ALL=C.UTF-8 shellcheck "$SCRIPT_FILE"

mkdir -p "$( dirname "$OUTPUT" )"

cp "$SCRIPT_FILE" "$OUTPUT"

chmod +x "$OUTPUT"
