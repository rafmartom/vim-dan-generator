#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

plantuml ${CURRENT_DIR}/vim-dan-generator-graph.puml ${CURRENT_DIR}/vim-dan-generator-graph.png
shdoc < ${CURRENT_DIR}/scripts/helpers.sh > ${CURRENT_DIR}/docs/scripts/helpers-sh.md
#luadoc --noindexpage -d "docs" ./pandoc-filters/*.lua
#luadoc --noindexpage ./pandoc-filters/*.lua
ldoc --dir "docs" --not_luadoc pandoc-filters
#ldoc --dir "docs" pandoc-filters

#mv ./docs/files/* ./docs/
#rmdir ./docs/files
