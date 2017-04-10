#!/usr/bin/env bash

GIST_DIR="$HOME/.gist"

. vars.sh

has_requirements


# # # # # # # # # # # # # # # # # # # #
# show help immediately
if [ $# -eq 0 ] || [ "$1" == "help" ]; then
    help
    exit
fi


# # # # # # # # # # # # # # # # # # # #
# project token [path]
if [ "$1" == "token" ]; then
    shift

    set_token "$@"

    exit


elif [ "$1" == "list" ]; then
    shift

    OPEN_IN=false

    if has_parameter "-b" $@; then
        OPEN_IN="browser"
        shift
    elif has_parameter "-c" $@; then
        OPEN_IN="clipboard"
        shift
    fi

    GISTS=$(fetch_gists)

    if [ -z "$GISTS" ]; then
        printf "${YELLOW}No gists found ¯\_(ツ)_/¯${NORMAL}\n"
        exit
    fi

    GIST_COUNT=$(echo $GISTS | jq '. | length')

    for ((i=0; i<$GIST_COUNT; i++)); do
        GIST=$(echo $GISTS | jq -rM --arg i $i '.[($i | tonumber)]')

        GIST_ID=$(echo $GIST | jq -r '.id')
        GIST_DESC=$(echo $GIST | jq -r '.description')
        GIST_IS_PUBLIC=$(echo $GIST | jq -r '.public')

        if $GIST_IS_PUBLIC; then
            GIST_COLOR=$BLUE
        else
            GIST_COLOR=$YELLOW
        fi

        if $OPEN_IN; then
            printf "%d. ${GIST_COLOR}${GIST_ID}${NORMAL}: ${GIST_DESC}\n" $(($i+1))
        else
            printf "${GIST_COLOR}${GIST_ID}${NORMAL}: ${GIST_DESC}\n"
        fi
    done

    if $OPEN_IN; then
        printf "\n"
        read -p "Number to open (1..${GIST_COUNT}): " GIST_NO

        GIST=$(echo $GISTS | jq -rM --arg no $(($GIST_NO-1)) '.[($no | tonumber)]')

        if [ -z "$GIST" ]; then
            printf "${RED}Selected Gist not found ¯\_(ツ)_/¯${NORMAL}\n"
        fi

        if [ "$OPEN_IN" == "browser" ]; then
            GIST_URL=$(echo $GIST | jq -r '.html_url')
            open $GIST_URL
        elif [ "$OPEN_IN" == "clipboard" ]; then
            GIST_URL=$(echo $GIST | jq -r '.url')
            GIST_CONTENT=$(fetch_gist_content $GIST_URL)

            if pbcopy -h 2>&1 /dev/null; then
                echo "$GIST_CONTENT" | pbcopy
                printf "${GREEN}Gist copied to clipboard!${NORMAL}\n"
            elif xclip -h 2>&1 /dev/null; then
                echo "$GIST_CONTENT" | xclip
                printf "${GREEN}Gist copied to clipboard!${NORMAL}\n"
            fi
        fi
    fi

    exit


# # # # # # # # # # # # # # # # # # # #
# project search [string-to-search]
elif [ "$1" == "search" ]; then
    shift

    OPEN_IN=false

    if has_parameter "-b" $@; then
        OPEN_IN="browser"
        shift
    elif has_parameter "-c" $@; then
        OPEN_IN="clipboard"
        shift
    fi

    GISTS=$(search_in_gists_for $1)
    GIST_COUNT=$(echo $GISTS | jq '. | length')

    for ((i=0; i<$GIST_COUNT; i++)); do
        GIST=$(echo $GISTS | jq -rM --arg i $i '.[($i | tonumber)]')

        GIST_ID=$(echo $GIST | jq -r '.id')
        GIST_DESC=$(echo $GIST | jq -r '.description')
        GIST_IS_PUBLIC=$(echo $GIST | jq -r '.public')

        if $GIST_IS_PUBLIC; then
            GIST_COLOR=$BLUE
        else
            GIST_COLOR=$YELLOW
        fi

        printf "%d. ${GIST_COLOR}${GIST_ID}${NORMAL}: ${GIST_DESC}\n" $(($i+1))
    done

    printf "\n"
    read -p "Number to open (1..${GIST_COUNT}): " GIST_NO

    GIST=$(echo $GISTS | jq -rM --arg no $(($GIST_NO-1)) '.[($no | tonumber)]')

    if [ -z "$GIST" ]; then
        printf "${RED}Selected Gist not found ¯\_(ツ)_/¯${NORMAL}\n"
    fi

    if [ "$OPEN_IN" == "browser" ]; then
        GIST_URL=$(echo $GIST | jq -r '.html_url')
        open $GIST_URL
    elif [ "$OPEN_IN" == "clipboard" ]; then
        GIST_URL=$(echo $GIST | jq -r '.url')
        GIST_CONTENT=$(fetch_gist_content $GIST_URL)

        if pbcopy -h 2>&1 /dev/null; then
            echo "$GIST_CONTENT" | pbcopy
            printf "${GREEN}Gist copied to clipboard!${NORMAL}\n"
        elif xclip -h 2>&1 /dev/null; then
            echo "$GIST_CONTENT" | xclip
            printf "${GREEN}Gist copied to clipboard!${NORMAL}\n"
        fi
    fi

    exit

fi
