#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# shellcheck source=/dev/null
source "${SCRIPT_DIR/%scripts\/*/scripts}/_common_functions"

# Initial checks
INPUT_FILES=$(_get_files "$*" "f" "1" "" "") || exit 1
OUTPUT_DIR=$PWD

_main_task() {
    local FILE=$1
    local OUTPUT_DIR=$2
    local STD_OUTPUT
    local EXIT_CODE

    STD_OUTPUT=$(chmod +x "$FILE" 2>&1)
    EXIT_CODE=$?
    _log_error_result "$FILE" "$STD_OUTPUT" "$OUTPUT_DIR" "$EXIT_CODE" ""
}

_run_parallel_tasks "$INPUT_FILES"
_display_result_tasks "$OUTPUT_DIR"
