#!/bin/bash

########## ARGS ##########
monitor=${1:-0}

########## OPTIONS ##########
panel_height=16
font="Ubuntu Mono:size=11"
bgcolor="#224488"
selbg=$(herbstclient get window_border_active_color)
selfg='#101010'
sep="^bg()^fg($selbg)|"

########## VARIABLES ##########
geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format: WxH+X+Y
x=${geometry[0]}
y=${geometry[1]}
panel_width=190

# Functions
function uniq_linebuffered() {
    awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

########## Go! ##########
herbstclient --idle | {

    # Processing of events
    TAGS=( $(herbstclient tag_status $monitor) )
    windowtitle=""

    while true ; do
        # draw tags
        for i in "${TAGS[@]}" ; do
            case ${i:0:1} in
                '#')
                    # Tag is focused, and so is monitor
                    echo -n "^bg($selbg)^fg($selfg)"
                    ;;
                '+')
                    # Tag is focused, but monitor is not
                    echo -n "^bg(#9CA668)^fg(#141414)"
                    ;;
                ':')
                    # Tag is not focused, and is not empty
                    echo -n "^bg()^fg(#ffffff)"
                    ;;
                '!')
                    # The tag contains an urgent window
                    echo -n "^bg(#FF0675)^fg(#141414)"
                    ;;
                *)
                    # Otherwise
                    echo -n "^bg()^fg(#ababab)"
                    ;;
            esac
            # If tag is not empty, show it.
            if [[ "${i:0:1}" != '.' ]]; then
                echo -n "^ca(1,herbstclient focus_monitor $monitor && herbstclient use ${i:1}) "
                echo -n "${i:1:1}"
                if [[ "${i:0:1}" == "#" ]] || [[ "${i:0:1}" == "+" ]]; then
                    echo -n "${i:2}"
                fi
                echo -n " ^ca()"
            fi
        done
        echo -n "$sep"

        # Finish output
        echo

        # wait for next event
        read line || break
        cmd=( $line )
        # find out event origin
        case "${cmd[0]}" in
            tag*)
                #echo "reseting tags" >&2
                TAGS=( $(herbstclient tag_status $monitor) )
                ;;
            quit_panel|reload)
                exit
                ;;
            *)
                echo "Unknown event: ${cmd[0]}" >&2
                ;;
        esac
    done
} | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -ta l -bg "$bgcolor" -fg '#efefef'
