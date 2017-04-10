#!/usr/bin/env bash

printf "Updating gist ..."

GIST_VERSION_OLD=$(cd $GIST_DIR && git describe --tags)
GIST_VERSION_NEW=$(cd $GIST_DIR && git fetch -q && git describe --tags `git rev-list --tags --max-count=1`)

# # # # # # # # # # # # # # # # # # # #
# latest version already installed
if [ "$GIST_VERSION_OLD" == "$GIST_VERSION_NEW" ]; then
    printf "${CLEAR_LINE}${GREEN}You have the latest version: ${BOLD}${GIST_VERSION_OLD}-beta${NORMAL}\n"
    exit
fi

cd $GIST_DIR

# # # # # # # # # # # # # # # # # # # #
# checkout the latest tag
if git checkout -q $GIST_VERSION_NEW; then

    printf "\n"
    printf "${BLUE}"
    printf '%s\n' ' ______     __     ______     ______ '
    printf '%s\n' '/\  ___\   /\ \   /\  ___\   /\__  _\'
    printf '%s\n' '\ \ \__ \  \ \ \  \ \___  \  \/_/\ \/'
    printf '%s\n' ' \ \_____\  \ \_\  \/\_____\    \ \_\'
    printf '%s\n' '  \/_____/   \/_/   \/_____/     \/_/'
    printf "${NORMAL}\n"

    printf "${BLUE}Yessss! gist has been updated and is now on version ${BOLD}v${GIST_VERSION_NEW}-beta${NORMAL}\n"
    GIST_CHANGES=$(git log --pretty=oneline --abbrev-commit $GIST_VERSION_OLD..$GIST_VERSION_NEW)

    printf "\n"
    printf "${YELLOW}Changes since your last update:${NORMAL}\n"
    printf "============================================\n"
    echo -e "$GIST_CHANGES" | sed 's/^.\{8\}\(.*\)/- \1/g'

else
    printf "\n${RED}There was an error while updating to the latest version. Try again later.${NORMAL}\n"
fi
