#!/bin/bash
# Symlink the pre-commit hook

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

#if [[ ! -d ${CURRENT_DIR}/../.github/workflows ]];then
#    mkdir -p ${CURRENT_DIR}/../.github/workflows 
#fi
#ln -sf ${CURRENT_DIR}/workflows/* "${CURRENT_DIR}/../.github/workflows/"

ln -sf ${CURRENT_DIR}/hooks/pre-commit "${CURRENT_DIR}/../.git/hooks/pre-commit"
echo "Git hooks and Github Workflows installed successfully!"
