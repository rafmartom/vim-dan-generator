#!/bin/bash

# ==============================================
# DOCUMENT PACKAGING AND RELEASE SCRIPT
# ==============================================

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOCS_DIR="$CURRENT_DIR/../ready-docus"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
RELEASE_TAG="docus-release-$TIMESTAMP"
VERSION="1.0"

# Colors for help menu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${YELLOW}╔════════════════════════════════════════╗"
    echo -e "║   vim-dan-generator Release Script v$VERSION  ║"
    echo -e "╚════════════════════════════════════════╝${NC}"
    echo -e "${GREEN}Usage:${NC} $0 [OPTIONS]"
    echo
    echo -e "${GREEN}Options:${NC}"
    echo -e "  ${YELLOW}-h, --help${NC}          Show this help message"
    echo -e "  ${YELLOW}-c, --create-release${NC} Create new GitHub release and upload packages"
    echo -e "  ${YELLOW}-k, --keep-source${NC}    Keep original .dan/.tags files after packaging"
    echo -e "  ${YELLOW}-a, --keep-archive${NC}   Keep .tar.xz files after upload"
    echo -e "  ${YELLOW}-d, --dry-run${NC}        Simulate without actually creating/uploading"
    echo
    echo -e "${GREEN}Examples:${NC}"
    echo -e "  ${YELLOW}Basic usage${NC} (create release, upload, clean up):"
    echo -e "    $0 -c"
    echo
    echo -e "  ${YELLOW}Preserve source files${NC}:"
    echo -e "    $0 --create-release --keep-source"
    echo
    echo -e "  ${YELLOW}Dry run${NC} (test without changes):"
    echo -e "    $0 -c --dry-run"
    echo
    echo -e "${RED}Requirements:${NC}"
    echo -e "  - GitHub CLI (gh) installed and authenticated"
    echo -e "  - ready-docus/ directory with .dan/.tags files"
}

# Parse arguments
CREATE_RELEASE=0
KEEP_SOURCE=0
KEEP_ARCHIVE=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -c|--create-release)
            CREATE_RELEASE=1
            shift
            ;;
        -k|--keep-source)
            KEEP_SOURCE=1
            shift
            ;;
        -a|--keep-archive)
            KEEP_ARCHIVE=1
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=1
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Main script execution
echo -e "${GREEN}=== Starting document packaging process ===${NC}"

# Package documents
find "$DOCS_DIR" -name '*.dan' | while read -r dan_file; do
    docu_name=$(basename -s .dan "${dan_file}")
    base_name="${dan_file%.dan}"
    tags_file="${DOCS_DIR}/.tags${docu_name}"
    tar_file="${base_name}.tar.xz"
    
    if [ -f "$tags_file" ]; then
        echo -e "${GREEN}Packaging ${YELLOW}$docu_name${GREEN}...${NC}"
        if [ $DRY_RUN -eq 0 ]; then
            (
                cd "$(dirname "$dan_file")" && \
                XZ_OPT=-9 tar -cJf "$(basename "$tar_file")" \
                    "$(basename "$dan_file")" \
                    "$(basename "$tags_file")"
            )
            [ $KEEP_SOURCE -eq 0 ] && rm "$dan_file" "$tags_file"
        else
            echo -e "${YELLOW}[DRY RUN] Would package: $docu_name${NC}"
        fi
    fi
done

# Release handling
if [ -n "$(find "$DOCS_DIR" -name '*.tar.xz' -print -quit)" ]; then
    if [ $CREATE_RELEASE -eq 1 ]; then
        if [ $DRY_RUN -eq 0 ]; then
            echo -e "${GREEN}Creating release ${YELLOW}$RELEASE_TAG${GREEN}...${NC}"
            gh release create "$RELEASE_TAG" \
                --title "Document Release $TIMESTAMP" \
                --notes "Automated document package" \
                --repo rafmartom/vim-dan-generator
        else
            echo -e "${YELLOW}[DRY RUN] Would create release: $RELEASE_TAG${NC}"
        fi
    fi

    # Upload packages
    for tar_file in "$DOCS_DIR"/*.tar.xz; do
        echo -e "${GREEN}Uploading ${YELLOW}$(basename "$tar_file")${GREEN}...${NC}"
        if [ $DRY_RUN -eq 0 ]; then
            gh release upload "$RELEASE_TAG" \
                "$tar_file" \
                --clobber \
                --repo rafmartom/vim-dan-generator
            
            [ $KEEP_ARCHIVE -eq 0 ] && rm "$tar_file"
        else
            echo -e "${YELLOW}[DRY RUN] Would upload: $(basename "$tar_file")${NC}"
        fi
    done
else
    echo -e "${RED}No documents found to package.${NC}"
fi

echo -e "${GREEN}=== Process completed ===${NC}"
