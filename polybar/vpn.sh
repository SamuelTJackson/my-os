#!/bin/bash

service="$1"; shift

if [ ! "$(nmcli c show --active | grep ${service})" ]; then
	echo '%{F#000000}'
else
	echo '%{F#98971a}'
fi

enable() {
	nmcli c up "$service"
}

disable() {
	nmcli c down "$service"
}

toggle() {
	if [ ! "$(nmcli c show --active | grep ${service})" ]; then
		nmcli c up "$service"
	else
		nmcli c down "$service"
	fi
}

"$@"
