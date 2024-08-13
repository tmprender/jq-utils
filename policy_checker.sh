#!/bin/bash

JSON_INPUT=$1
POLICY_DIR=$2

if [ -z "$JSON_INPUT" ] || [ -z "$POLICY_DIR" ]; then
    echo "Usage: $0 <json-input-file> <policy-directory>"
    exit 1
fi

FAIL_COUNT=0
ERROR_COUNT=0
for policy in "$POLICY_DIR"/*.jq; do
    RESULT=$(jq -f "$policy" "$JSON_INPUT")
    if [ $? -eq 0 ]; then
        if [ -z "$RESULT" ]; then
            echo "PASSED: Policy $(basename "$policy") passed."
        else
            echo "FAILED: Policy $(basename "$policy") violated. See details:"
            echo "$RESULT"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo "ERROR: Policy $(basename "$policy") did not run succesfully."
        echo "$RESULT"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

if [ $FAIL_COUNT -gt 0 ]; then
    echo "$FAIL_COUNT policy violations."
    echo "$ERROR_COUNT tests exited with errors."
    exit 1
else
    echo "All policies passed successfully."
    exit 0
fi

