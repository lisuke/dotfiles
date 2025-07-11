#!/bin/sh

hyprpicker | wl-copy
convert -size 100x100 xc:$(wl-paste) /tmp/hyprpicker.png
dunstify --icon=/tmp/hyprpicker.png "$(wl-paste)"  "Copied!"
