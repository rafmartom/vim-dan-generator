#!/bin/bash

# Package documentation files and create GitHub releases
#
# Usage: ./package-docus.sh [--create-release] [--keep-source] [--keep-archive]
# Options:
#   --create-release  Create GitHub release and upload packages
#   --keep-source     Keep original .dan/.tags files after packaging
#   --keep-archive    Keep .tar.xz files after upload
# Example:
#   ./package-docus.sh --create-release --keep-source

# Show help if no arguments or -h flag provided
if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ $# -eq 0 ]; then
  head -n 11 "$0" | tail -n +3
  exit 0
fi

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCS_DIR="$CURRENT_DIR/../ready-docus"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RELEASE_TAG="docus-release-$TIMESTAMP"

# Parse arguments
CREATE_RELEASE=0
KEEP_SOURCE=0
KEEP_ARCHIVE=0

for arg in "$@"; do
  case "$arg" in
    --create-release)
      CREATE_RELEASE=1
      ;;
    --keep-source)
      KEEP_SOURCE=1
      ;;
    --keep-archive)
      KEEP_ARCHIVE=1
      ;;
  esac
done

# Package documents
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
        [ $KEEP_SOURCE -eq 0 ] && rm "$dan_file" "$tags_file"
    fi
done

# Create release only if we have files to upload
if [ -n "$(find "$DOCS_DIR" -name '*.tar.xz' -print -quit)" ]; then
    if [ $CREATE_RELEASE -eq 1 ]; then
        echo "Creating release $RELEASE_TAG"
        gh release create "$RELEASE_TAG" \
            --title "Document Release $TIMESTAMP" \
            --notes "Automated document package" \
            --repo rafmartom/vim-dan-generator
    fi

    # Upload packages
    for tar_file in "$DOCS_DIR"/*.tar.xz; do
        echo "Uploading $(basename "$tar_file")..."
        gh release upload "$RELEASE_TAG" \
            "$tar_file" \
            --clobber \
            --repo rafmartom/vim-dan-generator
        
        [ $KEEP_ARCHIVE -eq 0 ] && rm "$tar_file"
    done
else
    echo "No documents found to package."
fi
