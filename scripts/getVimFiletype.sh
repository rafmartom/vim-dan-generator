#!/bin/bash

## Gets the vim syntax type out of a file extension
## Example : ./getVimFiletype.sh gradle
## Return : groovy

EXT=${1}

# Use nvim in headless mode to capture filetype
nvim --headless -c "0put=&filetype" -c "wq" /tmp/file.${EXT}
head -n 1 /tmp/file.${EXT}
