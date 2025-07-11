#!/usr/bin/env bash

# gtk
set_gtk() {
	set_light() {
		theme=Breeze
		dark_mode=0
		color_scheme=prefer-light
		echo "gtk light"

		# xwayland
		sed -i "s/Net\/ThemeName\ .*/Net\/ThemeName\ \"$theme\"/g" ~/.config/xsettingsd/xsettingsd.conf

		# gtk 2
		sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$theme\"/g" ~/.gtkrc-2.0
		# gtk 3
		sed -i "s/gtk-theme-name=.*/gtk-theme-name=$theme/g" ~/.config/gtk-3.0/settings.ini
		sed -i "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$dark_mode/g" ~/.config/gtk-3.0/settings.ini
		# gtk 4
		gsettings set org.gnome.desktop.interface gtk-theme $theme
		gsettings set org.gnome.desktop.interface color-scheme $color_scheme
	}
	set_dark() {
		theme=Breeze-Dark
		dark_mode=1
		color_scheme=prefer-dark
		echo "gtk dark"

		# xwayland
		sed -i "s/Net\/ThemeName\ .*/Net\/ThemeName\ \"$theme\"/g" ~/.config/xsettingsd/xsettingsd.conf

		# gtk 2
		sed -i "s/gtk-theme-name=.*/gtk-theme-name=\"$theme\"/g" ~/.gtkrc-2.0
		# gtk 3
		sed -i "s/gtk-theme-name=.*/gtk-theme-name=$theme/g" ~/.config/gtk-3.0/settings.ini
		sed -i "s/gtk-application-prefer-dark-theme=.*/gtk-application-prefer-dark-theme=$dark_mode/g" ~/.config/gtk-3.0/settings.ini
		# gtk 4
		gsettings set org.gnome.desktop.interface gtk-theme $theme
		gsettings set org.gnome.desktop.interface color-scheme $color_scheme
	}
	case "$1" in
	"light")
		set_light
		;;
	"dark")
		set_dark
		;;
	esac
	
	# hacking: apply to qt-theme
	pkill xsettingsd; sleep 1; xsettingsd &
}

# nvim
set_nvim() {
	set_light() {
		echo "nvim light"
	}
	set_dark() {
		echo "nvim dark"
	}
	case "$1" in
	"light")
		set_light
		;;
	"dark")
		set_dark
		;;
	esac
}

notify() {
	notify-send -a "THEMES" "Changing theme to $1" -i computer -r 2593 -u normal
	canberra-gtk-play -i audio-volume-change -d "Changing theme to $1"
}
case $1 in
"all")
	set_gtk $2
	set_nvim $2
	;;

"gtk")
	set_gtk $2
	;;

"nvim")
	set_nvim $2
	;;

*)
	echo "args: [all|gtk|nvim|foot] [light|dark]"
	exit
	;;
esac

notify $2
