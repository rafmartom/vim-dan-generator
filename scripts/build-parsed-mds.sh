#!/usr/bin/env bash
# Build an EGID that mirrors every .md of a repo, one block per file.
# Re-run any time (the pre-commit hook does it automatically):
#   scripts/build-parsed-mds.sh
set -euo pipefail

### Build an EGID that mirrors every .md of a repo, one block per file ----
# vars
REPO_ROOT=$(git rev-parse --show-toplevel)
DOC_REL=danotes/egid/parsed-mds.md
DOC_PATH="$REPO_ROOT/$DOC_REL"
DOC_TO_ROOT=../..                   # from $(dirname $DOC_REL) back to the repo root
#TOC_PREFIX=""                      # toc_path == repo-relative path (stable across branch renames)
TOC_PREFIX=/src/branch/main         # forgejo-style browse path

# YAML single-quoted scalar: escapes ' as '' so odd filenames cannot break the recipe
sq() { local s=${1//\'/\'\'}; printf "'%s'" "$s"; }

# 1. collect the markdown files (tracked + untracked-not-ignored, minus danotes/), NUL-safe
mapfile -d '' -t md_files < <(
  cd "$REPO_ROOT" && git ls-files -z --cached --others --exclude-standard '*.md' ':!:danotes/'
)
(( ${#md_files[@]} )) || { echo "error: no .md files under $REPO_ROOT" >&2; exit 1; }

# 2. form the recipe: static front matter, then one block line per file
recipe=$(cat <<YAML
label: Parsed markdown files
description: Every .md of the repository as its own block, re-readable with document source.
tags: [markdown, repo, snapshot]
blocks:
YAML
)
for f in "${md_files[@]}"; do
  [[ $f == *'${'* ]] && { echo "skipping (var-like name): $f" >&2; continue; }
  name=$(basename "$f")            # label/title from the filename
  recipe+=$'\n'"- {label: $(sq "$name"), toc_path: $(sq "${TOC_PREFIX}/${f}"), title: $(sq "$name"), source: {file: $(sq "${DOC_TO_ROOT}/${f}")}}"
done

# 3. (re)create the document: --force rebuilds the block set from the current file list
#    (blocks land pending; nothing is read yet; any hand-added ugb block is discarded)
mkdir -p "$(dirname "$DOC_PATH")"
danotes2 document new "$DOC_PATH" --force --file-recipe "$recipe" 2>&1 | grep -v '^warning: ' || true

# 4. source every block (file sources need no --allow)
danotes2 document source "$DOC_PATH" 2>&1 | grep -v '^warning: \|^{' || true
danotes2 block list "$DOC_PATH" --status
### ---------------------------------------------------------------------
