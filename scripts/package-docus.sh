#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCS_DIR="$CURRENT_DIR/../ready-docus"
TIMESTAMP=$(date +%Y%m%d%H%M%S)


find "$DOCS_DIR" -name '*.dan' | while read -r dan_file; do

    docu_name=$(basename -s .dan ${dan_file})
    base_name="${dan_file%.dan}"
    tags_file="${DOCS_DIR}/.tags${docu_name}"
    tar_file="${base_name}.tar.xz"
    
    if [ -f "$tags_file" ]; then
        echo "Packaging $base_name..."
        # Using subshell to avoid cd affecting main script
        (
            cd "$(dirname "$dan_file")" && \
            XZ_OPT=-9 tar -cJf "$(basename "$tar_file")" \
                "$(basename "$dan_file")" \
                "$(basename "$tags_file")"
        )
        rm "$dan_file" "$tags_file"
    fi
done

# Optional: Auto-create tag
if [ "$1" = "--create-tag" ]; then
    git tag "docus-release-$TIMESTAMP"
    echo "Created tag: docus-release-$TIMESTAMP"
    echo "Run 'git push origin --tags' to push to remote"
fi
