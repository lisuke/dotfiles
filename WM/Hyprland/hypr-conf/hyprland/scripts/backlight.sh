#!/bin/sh


# brightnessctl

brightnessctl_inc() {
    brightnessctl -q set 2%+
    brightness=$(brightnessctl -q get)
    notify-send -a "BRIGHTNESS" "Increasing to $brightness%" -h int:value:"$brightness" -i computer -r 2593 -u normal
    canberra-gtk-play -i audio-volume-change -d "Change monitor backlight"
}

brightnessctl_dec() {
    brightnessctl -q set 2%-
    brightness=$(brightnessctl -q get)
    notify-send -a "BRIGHTNESS" "Decreasing to $brightness%" -h int:value:"$brightness" -i computer -r 2593 -u normal
    canberra-gtk-play -i audio-volume-change -d "Change monitor backlight"
}


if [[ $1 == "brightnessctl" ]]; then
    case "$2" in
        inc)    brightnessctl_inc;;
        dec)    brightnessctl_dec;;
    esac
else
    echo "args: [brightnessctl] [inc|dec]"
fi
