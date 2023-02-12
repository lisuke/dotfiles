#!/bin/sh

hyprctl hyprpaper unload all
hyprctl hyprpaper preload $1
hyprctl hyprpaper wallpaper eDP-1,$1

# random script
# WALLPAPER=$(find ${HOME}/.config/hypr/wallpapers -type f | shuf -n 1)
# hyprctl hyprpaper unload all
# hyprctl hyprpaper preload $WALLPAPER
# hyprctl hyprpaper wallpaper eDP-1,$WALLPAPER
