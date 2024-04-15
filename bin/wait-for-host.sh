#!/bin/bash

PING=$(which ping)

function waitForHost {
	reachable=0
	while [ $reachable -eq 0 ]; do
		$PING -q -c 1 $1
		if [ "$?" -eq 0 ]; then
			reachable=1
		fi
	done
	sleep 1
}

if [ -n "$1" ]; then
	waitForHost $1
else
	echo "waitForHost: Hostname argument expected"
fi
