#!/bin/bash
#
#
speak_profile='handsfree_head_unit'
listen_profile='a2dp_sink'

card=$(pacmd list-cards | grep 'name:' | grep bluez | cut -d: -f2 | sed -e 's/[< >]//g')
current_profile=$(pactl list cards | awk -v RS='' '/bluez/' | awk -F': ' '/Active Profile/ { print $2 }')

if [[ "$current_profile" == "$speak_profile" ]]; then
	echo '%{F#98971a}'
else
	echo '%{F#000000}'
fi

toggle() {
  if [[ "$current_profile" == "$speak_profile" ]]; then
    pactl set-card-profile $card $listen_profile
  fi
  
  if [[ "$current_profile" == "$listen_profile" ]]; then
    pactl set-card-profile $card $speak_profile
  fi
}

"$@"
