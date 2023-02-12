#!/bin/sh

down() {
    brightnessctl -q set 2%-
    brightness=$(light -G)
    dunstify -a "BRIGHTNESS" "Decreasing to $brightness%" -h int:value:"$brightness" -i display-brightness-symbolic -r 2593 -u normal
}

up() {
    brightnessctl -q set 2%+
    brightness=$(light -G)
    dunstify -a "BRIGHTNESS" "Increasing to $brightness%" -h int:value:"$brightness" -i display-brightness-symbolic -r 2593 -u normal
}

case "$1" in
    up)     up;;
    down)   down;;
esac
