#!/bin/bash

function spawn_with_rules() {
    (
        if [[ ${RULES[0]} == "pid" ]]; then
            RULES[0]="pid=$BASHPID"
        fi

        herbstclient rule once maxage=30 "${RULES[@]}"
        exec "$@"
    ) 1>/dev/null 2>/dev/null &
}

RULES=( pid tag=1 )
spawn_with_rules fxnightly -P default

RULES=( name=zsh tag=2 )
spawn_with_rules urxvtc -e zsh -c irc
