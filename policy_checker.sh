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
    # Run the jq command and capture the output and the exit code
    RESULT=$(jq -f "$policy" "$JSON_INPUT" 2>&1)
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        if [ -n "$RESULT" ]; then
            echo "Policy $(basename "$policy") failed: Misconfigurations detected."
            echo "$RESULT"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        else
            echo "Policy $(basename "$policy") passed: No issues detected."
        fi
    else
        echo "Policy $(basename "$policy") encountered an error: Invalid jq syntax or runtime error."
        echo "$RESULT"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
done

if [ $ERROR_COUNT -gt 0 ]; then
    echo "$ERROR_COUNT policy(s) encountered errors."
fi

if [ $FAIL_COUNT -gt 0 ]; then
    echo "$FAIL_COUNT policy(s) failed. Exiting with errors."
    exit 1
elif [ $ERROR_COUNT -gt 0 ]; then
    echo "Some policies encountered errors. Exiting with errors."
    exit 1
else
    echo "All policies passed successfully."
    exit 0
fi

