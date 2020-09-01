#!/usr/bin/env bash

if [ $(command -v picom 2>/dev/null) ]; then
  if pgrep -x "picom" >/dev/null; then
    killall picom
  else
    [ -f "$DESKTOP_SESSION_CONFDIR/picom.conf" ] && picom -b --config $DESKTOP_SESSION_CONFDIR/picom.conf ||
      [ -f "$DESKTOP_SESSION_CONFDIR/compton.conf" ] && picom -b --config $DESKTOP_SESSION_CONFDIR/compton.conf ||
      picom -b
  fi

elif [ $(command -v compton 2>/dev/null) ]; then
  if pgrep -x "compton" >/dev/null; then
    killall compton
  else
    [ -f "$DESKTOP_SESSION_CONFDIR/picom.conf" ] && compton -b --config $DESKTOP_SESSION_CONFDIR/picom.conf ||
      [ -f "$DESKTOP_SESSION_CONFDIR/compton.conf" ] && compton -b --config $DESKTOP_SESSION_CONFDIR/compton.conf ||
      compton -b
  fi
fi
