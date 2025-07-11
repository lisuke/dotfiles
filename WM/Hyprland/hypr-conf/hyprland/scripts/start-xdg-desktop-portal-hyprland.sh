#!/usr/bin/env bash

sleep 1
killall xdg-desktop-portal{,-gtk,-kde,-wlr,-lxqt,-gnome,-hyprland}
sleep 1
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2
/usr/lib/xdg-desktop-portal &
sleep 1
