#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# output manipulation
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"
CLEAR_LINE="\r\033[K"

GIST_DIR=$HOME/.gist
GIST_CONFIG=$GIST_DIR/config.json
GIST_CACHE_DIR=$GIST_DIR/cache
GIST_CACHE_ALL=$GIST_CACHE_DIR/all.json

. functions.sh
