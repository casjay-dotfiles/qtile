#!/usr/bin/env bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# @Author      : Jason
# @Contact     : casjaysdev@casjay.net
# @File        : autostart.sh
# @Created     : Mon, Feb 24, 2020, 00:00 EST
# @License     : WTFPL
# @Copyright   : Copyright (c) CasjaysDev
# @Description : autostart script for qtile
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Set functions

# Functions

cmd_exist() {
  unalias "$1" >/dev/null 2>&1
  command -v "$1" >/dev/null 2>&1
}
__kill() {
  kill -9 "$(pidof "$1")" >/dev/null 2>&1
}
__start() {
  sleep 1 && "$@" >/dev/null 2>&1 &
}
__running() {
  pidof "$1" >/dev/null 2>&1
}

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# sudo password using dmenu

if cmd_exist dmenupass; then
  export SUDO_ASKPASS="dmenupass"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# export desktop session

export DESKTOP_SESSION="${DESKTOP_SESSION:-qtile}"

# set config dir

export DESKTOP_SESSION_CONFDIR="$HOME/.config/$DESKTOP_SESSION"

# export resolution

export RESOLUTION="$(xrandr --current | grep '*' | uniq | awk '{print $1}')"

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Panel - not needed for awesome qtile xmonad

#if cmd_exist polybar ; then
#    __kill polybar
#   __start "$HOME/.config/polybar/launch.sh"
#elif cmd_exist tint2 ; then
#    __kill tint2
#    __start tint2 -c "$HOME/.config/tint2/tint2rc"
#elif cmd_exist lemonbar ; then
#    __kill lemonbar
#   __start "$HOME/.config/lemonbar/lemonbar.sh"
#fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# setup keyboard

if cmd_exist ibus-daemon; then
  __kill ibus-daemon
  __start ibus-daemon --xim -d
fi

if cmd_exist ibus; then
  __kill ibus
  __start ibus
elif cmd_exist fcitx; then
  __kill fcitx
  __start fcitx
fi

if cmd_exist sxhkd; then
  __kill sxhkd
  __start sxhkd -c "$HOME/.config/sxhkd/sxhkdrc"
elif cmd_exist setxkbmap; then
  __kill setxkbmap
  __start setxkbmap -model pc104 -layout us -option "terminate:ctrl_alt_bksp"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Start window compositor

if cmd_exist picom; then
  __kill picom
  __start picom -b --config "$DESKTOP_SESSION_CONFDIR/compton.conf"
elif cmd_exist compton; then
  __kill compton
  __start compton -b --config "$DESKTOP_SESSION_CONFDIR/compton.conf"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# test for an existing bus daemon, just to be safe

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
  if cmd_exist dbus-launch; then
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

if cmd_exist xsettingsd; then
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
elif cmd_exist dunst; then
  __kill dunst
  __start dunst
elif cmd_exist deadd-notification-center; then
  __kill deadd-notification-center
  __start deadd-notification-center
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# sleep for 10 seconds

sleep 10

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# vmware tools

if cmd_exist vmware-user-suid-wrapper && ! __running vmware-user-suid-wrapper; then
  __kill vmware-user-suid-wrapper
  __start vmware-user-suid-wrapper
fi

if cmd_exist vmware-user && ! __running vmware-user; then
  __kill vmware-user
  __start vmware-user
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# start conky

if cmd_exist conky; then
  __kill conky
  __start conky -c "$DESKTOP_SESSION_CONFDIR/conky.conf"
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Wallpaper manager

if cmd_exist nitrogen; then
  __kill nitrogen
  __start nitrogen --restore
elif cmd_exist feh; then
  __kill feh
  __start feh --bg-fill "$DESKTOP_SESSION_CONFDIR/background.jpg"
elif cmd_exist variety; then
  __kill variety
  __start variety
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Network Manager

if cmd_exist nm-applet; then
  __kill nm-applet
  __start nm-applet
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Package Manager

if cmd_exist check-for-updates; then
  __start check-for-updates
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# bluetooth

if cmd_exist blueberry-tray; then
  __kill blueberry-tray
  __start blueberry-tray
elif cmd_exist blueman-applet; then
  __kill blueman-applet
  __start blueman-applet
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# num lock activated

if cmd_exist numlockx; then
  __kill numlockx
  __start numlockx on
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# volume

if cmd_exist volumeicon; then
  __kill volumeicon
  __start volumeicon
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# clipman

if cmd_exist xfce4-clipman; then
  __kill xfce4-clipman
  __start xfce4-clipman
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# PowerManagement

if cmd_exist xfce4-power-manager; then
  __kill xfce4-power-manager
  __start xfce4-power-manager
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Session

# if cmd_exist xfce4-session; then
#   __kill xfce4-session
#   __start xfce4-session
# fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Screenkey

#if cmd_exist screenkey ; then
#    __kill screenkey
#    __start screenkey
#fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# mpd

if cmd_exist mpd && ! __running mpd; then
  __start mpd
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# transmission

if cmd_exist transmission-daemon && ! __running transmission-daemon; then
  __start transmission-daemon
elif cmd_exist transmission-gtk && ! __running transmission-gtk; then
  __start transmission-gtk -m
elif cmd_exist transmission-remote-gtk && ! __running transmission-remote-gtk && __running transmission-daemon; then
  __start transmission-remote-gtk -m
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Welcome Message

if cmd_exist notify-send; then
  sleep 90 && notify-send --app-name="$DESKTOP_SESSION" "Welcome $USER to $DESKTOP_SESSION Desktop" &
fi

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

sleep 10
unset -f cmd_exist __kill __start

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

## End ##

# vim: set sw=2 noai :
