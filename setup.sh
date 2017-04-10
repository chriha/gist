#!/usr/bin/env bash

GIST_DIR="$HOME/.gist"
GIST_CACHE_DIR="$HOME/.gist/cache"
GIST_BIN_DIR="$HOME/.bin"
GIST_SYSTEM=$(uname -s)

# # # # # # # # # # # # # # # # # # # #
# output manipulation
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

# # # # # # # # # # # # # # # # # # # #
# oh-my-zsh installed
if [ -f "$HOME/.zshrc" ]; then
    BASH_RC="$HOME/.zshrc"

# # # # # # # # # # # # # # # # # # # #
# mac OSX and .bash_profile
elif [ $GIST_SYSTEM = 'Darwin' ] && [ -f "$HOME/.bash_profile" ]; then
    BASH_RC="$HOME/.bash_profile"

# # # # # # # # # # # # # # # # # # # #
# mac OSX and .profile
elif [ $GIST_SYSTEM = 'Darwin' ] && [ -f "$HOME/.profile" ]; then
    BASH_RC="$HOME/.profile"

# # # # # # # # # # # # # # # # # # # #
# last try with the .bashrc
else
    BASH_RC="$HOME/.bashrc"
fi

# # # # # # # # # # # # # # # # # # # #
# couldn't find the bash resource, so abort
if [ -z "$BASH_RC" ]; then
    printf "${RED}Unable to find bash resource!${NORMAL}"
    exit
fi

printf "Installing gist ....\n"

mkdir -p $GIST_BIN_DIR
mkdir -p $GIST_CACHE_DIR

# # # # # # # # # # # # # # # # # # # #
# check if the .bin directory is already part of $PATH in the
# resource file and if not, add it!
grep -E 'export PATH=.*(\~\/|\$HOME\/)\.bin.*\$PATH' $BASH_RC > /dev/null || echo 'export PATH=~/.bin:$PATH' >> $BASH_RC

ln -sf $GIST_DIR/gist.sh $GIST_BIN_DIR/gist

printf "${BLUE}"
printf '%s\n' ' ______     __     ______     ______ '
printf '%s\n' '/\  ___\   /\ \   /\  ___\   /\__  _\'
printf '%s\n' '\ \ \__ \  \ \ \  \ \___  \  \/_/\ \/'
printf '%s\n' ' \ \_____\  \ \_\  \/\_____\    \ \_\'
printf '%s\n' '  \/_____/   \/_/   \/_____/     \/_/'
printf "${NORMAL}\n"

# fetch latest version
GIST_VERSION=$( cd $GIST_DIR && git describe --tags `git rev-list --tags --max-count=1` )

printf "${BLUE}Yessss! pro-cli has been installed and is now on version ${BOLD}v${GIST_VERSION}-beta${NORMAL}.\n\n"