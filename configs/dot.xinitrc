if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Non reparenting window manager. Fixes Minecraft.
export _JAVA_AWT_WM_NONREPARENTING=1

# This has to be set early, so that herbstluftwm and others get it.
export PATH="${HOME}/bin:${PATH}"

# Enable scrolling with the TrackPoint.
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5

# Set up compose key
setxkbmap -option compose:caps
export GTK_IM_MODULE="xim"

# Load .Xresources file, if it exists
[ -f ~/.Xresources ] && xrdb ~/.Xresources

# Some Daemons
pulseaudio &
urxvtd &
#source <(gnome-keyring-daemon)

export SSH_AUTH_SOCK
export GPG_AGENT_INFO
export GNOME_KEYRING_CONTROL
export GNOME_KEYRING_PID

# # Things to do after hlwm starts.
# {
#     sleep 1
#     ${HOME}/.config/herbstluftwm/apps.sh
#  
#     # Set resolutions for monitors.
#     ${HOME}/bin/monfix
# } &

exec herbstluftwm
