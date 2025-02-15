#!/bin/bash

# Create relevant json files in a revisions directory
# Store the mcbroken-archive repo in the same directory as this one

EXPORT_TO=../mcbroken-daily/revisions
GIT_PATH_TO_FILE=mcbroken.json

USAGE="Please cd to the root of your git project and specify the path to the file you wish to inspect (example: $0 some/path/to/file)"
cd ../mcbroken-archive

if [ -z "$GIT_PATH_TO_FILE" ]; then
    echo "error: no arguments given. ${USAGE}" >&2
    exit 1
fi

if [ ! -f "$GIT_PATH_TO_FILE" ]; then
    echo "error: File '$GIT_PATH_TO_FILE' does not exist. ${USAGE}" >&2
    exit 1
fi

GIT_SHORT_FILENAME=$(basename "$GIT_PATH_TO_FILE")

if [ ! -d "$EXPORT_TO" ]; then
    echo "Creating folder: $EXPORT_TO"
    mkdir "$EXPORT_TO"
fi

COUNT=0

git rev-list --all --objects -- "$GIT_PATH_TO_FILE" | cut -d ' ' -f1 | while read -r h; do
    COMMIT_MSG=$(git log -1 --format=%s "$h")

    if [[ "$COMMIT_MSG" == *" 19:"* ]]; then
        COUNT=$((COUNT + 1))
        COUNT_PRETTY=$(printf "%04d" $COUNT)

        # Sanitize commit message for filename
        SAFE_COMMIT_MSG=$(echo "$COMMIT_MSG" | tr ' ' '_' | tr -d ':"')

        OUTPUT_FILE="$EXPORT_TO/$COUNT_PRETTY.$SAFE_COMMIT_MSG.$h.$GIT_SHORT_FILENAME"
        
        git cat-file -p "$h":"$GIT_PATH_TO_FILE" > "$OUTPUT_FILE"
        echo "Saved commit from 11 AM PST: $OUTPUT_FILE"
    fi
done

echo "Result stored in $EXPORT_TO"
exit 0
