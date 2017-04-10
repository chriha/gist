#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # #
# get the users bash profile
get_bash_rc() {
    # # # # # # # # # # # # # # # # # # # #
    # oh-my-zsh installed
    if [ -f "$HOME/.zshrc" ]; then
        echo "$HOME/.zshrc"

    # # # # # # # # # # # # # # # # # # # #
    # mac OSX and .bash_profile
    elif [ $PC_SYSTEM = 'Darwin' ] && [ -f "$HOME/.bash_profile" ]; then
        echo "$HOME/.bash_profile"

    # # # # # # # # # # # # # # # # # # # #
    # mac OSX and .profile
    elif [ $PC_SYSTEM = 'Darwin' ] && [ -f "$HOME/.profile" ]; then
        echo "$HOME/.profile"

    # # # # # # # # # # # # # # # # # # # #
    # last try with the .bashrc
    else
        echo "$HOME/.bashrc"
    fi
}


# # # # # # # # # # # # # # # # # # # #
# shows the help
help() {
    # spaces until the commands descriptions starts
    SPACE="                      "

    printf "    ${BLUE}gist ${BOLD}v${PC_VERSION}-beta${NORMAL}\n"
    printf "\n"
    printf "    help: gist [command]\n"
    printf "\n"
    printf "    COMMANDS:\n"
    printf "        ${BLUE}token${NORMAL}${SPACE:5}Set Github API token.\n"
    printf "        ${BLUE}search${NORMAL}${SPACE:6}Search your Github gists.${NORMAL}\n"
    printf "        ${BLUE}list${NORMAL}${SPACE:4}List your gists.${NORMAL}\n"
    printf "\n"
}


# # # # # # # # # # # # # # # # # # # #
# get unix timestamp from file
filemtime() {
    local SYSTEM=$(uname -s)

    local TIMESTAMP=0

    if [ "$SYSTEM" == "Darwin" ]; then
        if stat -f %y $1 &> /dev/null; then
            local CHANGED=$(stat -f %m $1)
        elif php -v &> /dev/null; then
            local CHANGED=$(php -r "echo filemtime('${1}');" 2> /dev/null)
        fi

        if [ ! -z "$CHANGED" ]; then
            TIMESTAMP=$(expr $(date +%s) - $(printf "%.0f" $CHANGED))
        fi
    else
        local CHANGED=$(stat -c %Y $1)

        TIMESTAMP=$(expr $(date +%s) - $(printf "%.0f" $CHANGED))
    fi

    echo $TIMESTAMP
}


# # # # # # # # # # # # # # # # # # # #
# check the requirements
has_requirements() {
    if ! jq -h &> /dev/null; then
        printf "${RED}jq is missing on your system: https://github.com/stedolan/jq${NORMAL}\n"
        exit
    fi

    validate_config
}


validate_config() {
    if [ ! -f "$GIST_CONFIG" ]; then
        echo '{ "token": null }' | jq -M . > $GIST_CONFIG
    fi
}


get_token() {
    local TOKEN=$(cat $GIST_CONFIG | jq -r '.token')

    echo $TOKEN
}

set_token() {
    if [ -z "$1" ]; then
        read -p "Your token: " GIST_TOKEN
    else
        GIST_TOKEN=$1
    fi

    local JSON=$(cat $GIST_CONFIG | jq ".token = \"${GIST_TOKEN}\"" | jq -M .)

    echo $JSON > $GIST_CONFIG
}

has_parameter() {
    local PARAM=$1
    shift

    for var in "$@"; do
        if [ "$PARAM" == "$var" ]; then
            return 0
        fi
    done

    return 1
}

#get_version() {}

#has_new_version() {}

#is_cache_expired() {}

fetch_gist_content() {
    local URL="$1"
    local TOKEN=$(get_token)
    CONTENT=$(curl -s -H "Authorization: token ${TOKEN}" "$URL")

    echo $CONTENT | jq -r '.files[(.files | keys[0])].content'
}

fetch_list() {
    echo $(curl -s -H "Authorization: token ${TOKEN}" "${1}" -D /tmp/headers.txt 2>&1 | jq '.')
}

fetch_gists() {
    if [ -f $GIST_CACHE_ALL ]; then
        local CACHING_TIME=$(filemtime $GIST_CACHE_ALL)
    else
        local CACHING_TIME=0
    fi

    if [ $CACHING_TIME != 0 ] && [ $CACHING_TIME -gt 1800 ]; then
        cat $GIST_CACHE_ALL
        return 1
    fi

    local GCN_FILE=/tmp/gcn.json
    local TOKEN=$(get_token)
    local GISTS=$(fetch_list "https://api.github.com/gists")
    # local GISTS=$(curl -s -H "Authorization: token ${TOKEN}" "https://api.github.com/gists" -D /tmp/headers.txt 2>&1 | jq '.')
    local NEXT=$(cat /tmp/headers.txt | sed -n 's/^Link: <\(.*\)>; rel="next".*/\1/p')

    echo $GISTS > $GIST_CACHE_ALL

    while [ -n "$NEXT" ]; do
        fetch_list $NEXT > $GCN_FILE
        echo $(jq -s '.[0] + .[1]' $GIST_CACHE_ALL $GCN_FILE) > $GIST_CACHE_ALL

        local NEXT=$(cat /tmp/headers.txt | sed -n 's/^Link: <\(.*\)>; rel="next".*/\1/p')
    done

    cat $GIST_CACHE_ALL
}

#get_cache() {}

#set_cache() {}

search_in_gists_for() {
    local SEARCH=$1
    local GISTS=$(fetch_gists)

    echo $GISTS | jq --arg var "$1" '. | map( select(.description != null) ) | map( select(.description | contains( $var )) )'
}
