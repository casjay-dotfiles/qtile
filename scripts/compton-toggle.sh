#!/usr/bin/env bash
if pgrep -x "compton" > /dev/null
then
	killall compton
else
	compton -b --config $DESKTOP_SESSION_CONFDIR/compton.conf
fi
