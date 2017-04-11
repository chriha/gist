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

. $GIST_DIR/functions.sh

# current pro-cli version
GIST_VERSION=$(cd $GIST_DIR && git describe --tags)

if [ -f "$GIST_DIR/.git/FETCH_HEAD" ]; then
    GIST_HEAD_FILE="$GIST_DIR/.git/FETCH_HEAD"
else
    GIST_HEAD_FILE="$GIST_DIR/.git/HEAD"
fi

GIST_LATEST_FETCH=$(filemtime $GIST_HEAD_FILE)

# check for new version
if [ $GIST_LATEST_FETCH != 0 ] && [ $GIST_LATEST_FETCH -gt 1800 ]; then
    # only fetch every 30 minutes
    GIST_VERSION_NEW=$(cd $GIST_DIR && git fetch -q && git describe --tags `git rev-list --tags --max-count=1`)
elif [ $GIST_LATEST_FETCH != 0 ]; then
    GIST_VERSION_NEW=$(cd $GIST_DIR && git describe --tags `git rev-list --tags --max-count=1`)
fi

GIST_VERSION_SUFFIX="-beta"
