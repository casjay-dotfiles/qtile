#!/usr/bin/env bash

elif pgrep -x "picom" > /dev/null
then
  killall picom
else
  [ -f "$DESKTOP_SESSION_CONFDIR/picom.conf" ] && picom -b --config $DESKTOP_SESSION_CONFDIR/picom.conf ||
  [ -f "$DESKTOP_SESSION_CONFDIR/compton.conf" ] && picom -b --config $DESKTOP_SESSION_CONFDIR/compton.conf ||
  picom -b
fi

elif pgrep -x "compton" > /dev/null
then
  killall compton
else
  [ -f "$DESKTOP_SESSION_CONFDIR/picom.conf" ] && compton -b --config $DESKTOP_SESSION_CONFDIR/picom.conf ||
  [ -f "$DESKTOP_SESSION_CONFDIR/compton.conf" ] && compton -b --config $DESKTOP_SESSION_CONFDIR/compton.conf ||
  compton -b
fi
