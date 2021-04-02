#!/usr/bin/env bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
PROG="autostart.sh"
USER="${SUDO_USER:-${USER}}"
HOME="${USER_HOME:-${HOME}}"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#set opts

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version       : 021320212341-git
# @Author        : Jason Hempstead
# @Contact       : jason@casjaysdev.com
# @License       : WTFPL
# @ReadME        : autostart.sh --help
# @Copyright     : Copyright: (c) 2021 Jason Hempstead, CasjaysDev
# @Created       : Saturday, Feb 13, 2021 23:41 EST
# @File          : autostart.sh
# @Description   : autostart script for qtile
# @TODO          :
# @Other         :
# @Resource      :
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Help
[[ "$1" = *help ]] && printf "%s\n" "Usage: autostart.sh" "Starts applications for bspwm window manager" && exit

# Set functions
__pid() { ps -ux | grep " $1" | grep -v 'grep ' | awk '{print $2}' | grep ^ || return 1; }
__kill() { __running "$1" && kill -9 "$(__pid "$1")" >/dev/null 2>&1; }
__running() { __pid "$1" &>/dev/null && return 0 || return 1; }
__stopped() { __pid "$1" &>/dev/null && return 1 || return 0; }

__cmd_exist() {
  unalias "$1" >/dev/null 2>&1
  command -v "$1" >/dev/null 2>&1
}
__start() {
  local CMD="$1" && shift 1
  local ARGS="$*" && shift $#
  sleep .2
  $CMD $ARGS >/dev/null 2>&1 &
  disown
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# sudo password using dmenu
__cmd_exist dmenupass && SUDO_ASKPASS="dmenupass"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# set desktop session
DESKTOP_SESSION="${DESKTOP_SESSION:-qtile}"

# set config dir
DESKTOP_SESSION_CONFDIR="$HOME/.config/$DESKTOP_SESSION"

# set resolution
__cmd_exist xrandr && [ -n "$DISPLAY" ] &&
  RESOLUTION="$(xrandr --current | grep '*' | uniq | awk '{print $1}')"

# export setting
export SUDO_ASKPASS DESKTOP_SESSION DESKTOP_SESSION_CONFDIR RESOLUTION

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Panel - not needed for awesome i3 qtile sway xmonad
# if __stopped xfce4-panel; then
#   if __cmd_exist polybar; then
#     __kill polybar
#     __start "$HOME/.config/polybar/launch.sh"
#   elif __cmd_exist tint2; then
#     __kill tint2
#     __start tint2 -c "$HOME/.config/tint2/tint2rc"
#   elif __cmd_exist lemonbar; then
#     __kill lemonbar
#     __start "$HOME/.config/lemonbar/lemonbar.sh"
#   else
#     PANEL="none"
#   fi
#   if [ "$PANEL" = "none" ] && __cmd_exist xfce4-session && __cmd_exist xfce4-panel; then
#     __kill xfce4-panel
#     __start xfce4-panel
#   fi
# fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# setup keyboard
if __cmd_exist ibus-daemon; then
  __kill ibus-daemon
  __start ibus-daemon --xim -d
elif __cmd_exist ibus; then
  __kill ibus
  __start ibus
elif __cmd_exist fcitx; then
  __kill fcitx
  __start fcitx
fi

if __cmd_exist sxhkd; then
  __kill sxhkd
  __start sxhkd -c "$HOME/.config/sxhkd/sxhkdrc" -s "$HOME/.cache/sxhkd"
fi

if __cmd_exist setxkbmap; then
  __kill setxkbmap
  __start setxkbmap -model pc104 -layout us -option "terminate:ctrl_alt_bksp"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Start window compositor
if __cmd_exist picom; then
  __kill picom
  __start picom -b --config "$DESKTOP_SESSION_CONFDIR/compton.conf"
elif __cmd_exist compton; then
  __kill compton
  __start compton -b --config "$DESKTOP_SESSION_CONFDIR/compton.conf"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# test for an existing dbus daemon, just to be safe
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  if __cmd_exist dbus-launch; then
    dbus_args="--sh-syntax --exit-with-session"
    case "$DESKTOP_SESSION" in
    awesome) dbus_args+="awesome" ;;
    bspwm) dbus_args+="bspwm-session" ;;
    i3 | i3wm) dbus_args+="i3 --shmlog-size 0" ;;
    jwm) dbus_args+="jwm" ;;
    lxde) dbus_args+="startlxde" ;;
    lxqt) dbus_args+="lxqt-session" ;;
    xfce) dbus_args+="xfce4-session" ;;
    openbox) dbus_args+="openbox-session" ;;
    *) dbus_args+="$DEFAULT_SESSION" ;;
    esac
    __kill dbus-launch
    __start dbus-launch "${dbus_args[*]}"
  fi
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# xsettings
if __cmd_exist xsettingsd; then
  __kill xsettingsd
  __start xsettingsd -c "$DESKTOP_SESSION_CONFDIR/xsettingsd.conf"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Authentication dialog
# ubuntu
if [ -f /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1 ]; then
  __kill polkit-gnome-authentication-agent-1
  __start /usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1
# Fedora
elif [ -f /usr/libexec/polkit-gnome-authentication-agent-1 ]; then
  __kill polkit-gnome-authentication-agent-1
  __start /libexec/polkit-gnome-authentication-agent-1
# Arch
elif [ -f /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
  __kill polkit-gnome-authentication-agent-1
  __start /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#Notification daemon
if [ -f /usr/lib/xfce4/notifyd/xfce4-notifyd ]; then
  __kill xfce4-notifyd
  __start /usr/lib/xfce4/notifyd/xfce4-notifyd
elif [ -f /usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd ]; then
  __kill xfce4-notifyd
  __start /usr/lib/x86_64-linux-gnu/xfce4/notifyd/xfce4-notifyd
elif __cmd_exist dunst; then
  __kill dunst
  __start dunst
elif __cmd_exist deadd-notification-center; then
  __kill deadd-notification-center
  __start deadd-notification-center
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# vmware tools
if __cmd_exist vmware-user-suid-wrapper && ! __running vmware-user-suid-wrapper; then
  __kill vmware-user-suid-wrapper
  __start vmware-user-suid-wrapper
fi
if __cmd_exist vmware-user && ! __running vmware-user; then
  __kill vmware-user
  __start vmware-user
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# start conky
if __cmd_exist conky; then
  __kill conky
  __start conky -c "$DESKTOP_SESSION_CONFDIR/conky.conf"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Wallpaper manager
if __cmd_exist randomwallpaper; then
  __kill randomwallpaper
  __start randomwallpaper --bg --start
elif __cmd_exist variety; then
  __kill variety
  __start variety
elif __cmd_exist feh; then
  __kill feh
  __start feh --bg-fill "${WALLPAPERS:-/home/jason/.local/share/wallpapers}/system/default.jpg"
elif __cmd_exist nitrogen; then
  __kill nitrogen
  __start nitrogen --restore
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Network Manager
if __cmd_exist nm-applet; then
  __kill nm-applet
  __start nm-applet
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Package Manager
if __cmd_exist check-for-updates; then
  __kill check-for-updates
  __start check-for-updates
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# bluetooth
if __cmd_exist blueberry-tray; then
  __kill blueberry-tray
  __start blueberry-tray
elif __cmd_exist blueman-applet; then
  __kill blueman-applet
  __start blueman-applet
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# num lock activated
if __cmd_exist numlockx; then
  __kill numlockx
  __start numlockx on
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# volume
if __cmd_exist volumeicon; then
  __kill volumeicon
  __start volumeicon
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# clipman
if __cmd_exist xfce4-clipman; then
  __kill xfce4-clipman
  __start xfce4-clipman
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# PowerManagement
if __cmd_exist xfce4-power-manager; then
  __kill xfce4-power-manager
  __start xfce4-power-manager
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Session used if you want xfce4
# if __cmd_exist xfce4-session; then
#   __kill xfce4-session
#   __start xfce4-session
# fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Screenkey
#if __cmd_exist screenkey ; then
#    __kill screenkey
#    __start screenkey
#fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# mpd
if [ -z "$MPDSERVER" ] && __cmd_exist mpd && ! __running mpd; then
  __kill mpd
  __start mpd
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# transmission
if __cmd_exist mytorrent; then
  __kill mytorrent
  __start mytorrent
elif __cmd_exist transmission-daemon && ! __running transmission-daemon; then
  __start transmission-daemon
elif __cmd_exist transmission-gtk && ! __running transmission-gtk; then
  __start transmission-gtk -m
elif __cmd_exist transmission-remote-gtk && ! __running transmission-remote-gtk && __running transmission-daemon; then
  __start transmission-remote-gtk -m
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Welcome Message
if __cmd_exist notifications; then
  sleep 90 && notifications "$DESKTOP_SESSION" "Welcome $USER to $DESKTOP_SESSION Desktop" &
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# final
sleep 10
unset -f __cmd_exist __kill __start __pid
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
exit 0
# End
