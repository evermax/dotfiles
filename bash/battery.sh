#!/bin/bash
battery-status() {
    charged_icon="❇ "
    charging_icon="⚡️ "
    discharging_icon="🔋 "
    attached_icon="⚠️ "

    status=$(pmset -g batt | awk -F '; *' 'NR==2 { print $2 }')

    if [[ $status =~ (charged) ]]; then
        printf "$charged_icon"
    elif [[ $status =~ (^charging) ]]; then
        printf "$charging_icon"
    elif [[ $status =~ (^discharging) ]]; then
        printf "$discharging_icon"
    elif [[ $status =~ (attached) ]]; then
        printf "$attached_icon"
    fi
}

battery() {
    pmset -g batt | grep -o '[0-9]*%'
}

battery-remaining() {
    pmset -g batt | grep -o '[0-9]*:[0-9]*'
}
