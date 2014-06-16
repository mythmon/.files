#!/bin/bash

########## ARGS ##########
monitor=${1:-0}

########## OPTIONS ##########
panel_height=20
font="Fira Mono:size=12"
bgcolor="#224488"
selbg=$(herbstclient get window_border_active_color)
selfg='#101010'
sep="^bg()^fg($selbg)|"

net_dev="wlan0"

########## VARIABLES ##########
geometry=( $(herbstclient monitor_rect "$monitor") )
if [ -z "$geometry" ] ;then
    echo "Invalid monitor $monitor"
    exit 1
fi
# geometry has the format: WxH+X+Y
x=${geometry[0]}
#y=${geometry[1]}
y=$(( ${geometry[1]} + ${geometry[3]} - $panel_height ))
if [[ 0 -eq $monitor ]]; then
    panel_width=322
else
    panel_width=${geometry[2]}
fi

# Try to find textwidth binary.
# In e.g. Ubuntu, this is named dzen2-textwidth.
if [ -e "$(which textwidth 2> /dev/null)" ] ; then
    textwidth="textwidth";
elif [ -e "$(which dzen2-textwidth 2> /dev/null)" ] ; then
    textwidth="dzen2-textwidth";
else
    echo "This script requires the textwidth tool of the dzen2 project."
    exit 1
fi

# true if we are using the svn version of dzen2
dzen2_version=$(dzen2 -v 2>&1 | head -n 1 | cut -d , -f 1|cut -d - -f 2)
if [ -z "$dzen2_version" ] ; then
    dzen2_svn="true"
else
    dzen2_svn=""
fi

# Functions
function uniq_linebuffered() {
    awk '$0 != l { print ; l=$0 ; fflush(); }' "$@"
}

########## Go! ##########
herbstclient pad $monitor 5 5 $(( 5 + $panel_height )) 5

{
    # hlwm events
    herbstclient --idle

} | {

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
        #echo -n "^bg()^fg() ${windowtitle//^/^^}"

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
            focus_changed|window_title_changed)
                max=50
                title="${cmd[@]:2}"
                if [[ ${#title} -gt $max ]]; then
                    title="${title:0:$((max - 3))}..."
                fi
                windowtitle="${title}"
                ;;
            *)
                echo "Unknown event: ${cmd[0]}" >&2
        esac
    done
} | dzen2 -w $panel_width -x $x -y $y -fn "$font" -h $panel_height \
    -ta l -bg "$bgcolor" -fg '#efefef'
