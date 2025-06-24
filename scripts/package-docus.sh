#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCS_DIR="$CURRENT_DIR/../ready-docus"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RELEASE_TAG="docus-release-$TIMESTAMP"

# First package all documents
find "$DOCS_DIR" -name '*.dan' | while read -r dan_file; do
    docu_name=$(basename -s .dan "${dan_file}")
    base_name="${dan_file%.dan}"
    tags_file="${DOCS_DIR}/.tags${docu_name}"
    tar_file="${base_name}.tar.xz"
    
    if [ -f "$tags_file" ]; then
        echo "Packaging $docu_name..."
        (
            cd "$(dirname "$dan_file")" && \
            XZ_OPT=-9 tar -cJf "$(basename "$tar_file")" \
                "$(basename "$dan_file")" \
                "$(basename "$tags_file")"
        )
        [ "$2" != "--keep-source" ] && rm "$dan_file" "$tags_file"
    fi
done

# Create release only if we have files to upload
if [ -n "$(find "$DOCS_DIR" -name '*.tar.xz' -print -quit)" ]; then
    # Create new release first (only once)
    if [ "$1" = "--create-release" ]; then
        echo "Creating release $RELEASE_TAG"
        gh release create "$RELEASE_TAG" \
            --title "Document Release $TIMESTAMP" \
            --notes "Automated document package" \
            --repo rafmartom/vim-dan-generator
    fi

    # Upload all packages
    for tar_file in "$DOCS_DIR"/*.tar.xz; do
        echo "Uploading $(basename "$tar_file")..."
        gh release upload "$RELEASE_TAG" \
            "$tar_file" \
            --clobber \
            --repo rafmartom/vim-dan-generator
        
        [ "$2" != "--keep-archive" ] && rm "$tar_file"
    done
else
    echo "No documents found to package."
fi
