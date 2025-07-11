#!/bin/sh

# usage:
#	gtk setting tool
# 		backend: 	gsettings
# 		frontend:	nwg-look
config="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-3.0/settings.ini"
if [ ! -f "$config" ]; then exit 1; fi

gtk_theme="$(grep 'gtk-theme-name' "$config" | sed 's/.*\s*=\s*//')"
icon_theme="$(grep 'gtk-icon-theme-name' "$config" | sed 's/.*\s*=\s*//')"
cursor_theme="$(grep 'gtk-cursor-theme-name' "$config" | sed 's/.*\s*=\s*//')"
cursor_size="$(grep 'gtk-cursor-theme-size' "$config" | sed 's/.*\s*=\s*//')"
font_name="$(grep 'gtk-font-name' "$config" | sed 's/.*\s*=\s*//')"

gsettings set org.gnome.desktop.interface      gtk-theme      "$gtk_theme"
gsettings set org.gnome.desktop.interface      icon-theme     "$icon_theme"
gsettings set org.gnome.desktop.interface      cursor-theme   "$cursor_theme"
gsettings set org.gnome.desktop.interface      cursor-size    "$cursor_size"
gsettings set org.gnome.desktop.interface      font-name      "$font_name"

# gsettings set org.gnome.desktop.interface      scaling-factor 1

hyprctl setcursor "$cursor_theme" "$cursor_size"