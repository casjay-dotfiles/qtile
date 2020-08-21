#!/usr/bin/env bash

SCRIPTNAME="$(basename $0)"
SCRIPTDIR="$(dirname "${BASH_SOURCE[0]}")"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : weather.sh
# @Created     : Mon, Dec 31, 2019, 00:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : weather tool for conky 
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

printf_color() { printf "%b" "$(tput setaf "$2" 2> /dev/null)" "$1" "$(tput sgr0 2> /dev/null)" ;}
printf_green() { printf_color "$1" 2 ;}
printf_red() { printf_color "$1" 1 ;}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Specify langauge
LANG="$(echo $LANG | sed 's#_.*##g')"

# Should be u for f or m for c 
METRIC="u"

# Options - curl http://wttr.in/:help?A
[ ! -z "$1" ] && OPTS="$1" || OPTS="A$METRIC"

# Location ID
[ ! -z "$2" ] && LOC="$2" || LOC="${MYLOCATIONID:-alb}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if [ "$1" = "--help" ]; then
    printf_green "\t\tUSAGE: weather.sh <options> <locationcode>\n"
    printf_green "\t\tSee curl http://wttr.in/:help?A for all options\n"
    printf_green "\t\tIE: weather.sh Au0 mia\n"
    exit 0
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

curl -H "Accept-Language: $LANG" -Ls "http://wttr.in/$LOC?$OPTS" | sed -n '3,7{s/\d27\[[0-9;]*m//g;s/^..//;s/ *$//;p}'
curl -H "Accept-Language: $LANG" -Ls "http://wttr.in/$LOC?$OPTS" | grep "Weather report"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# end
#/* vi: set expandtab ts=4 noai
