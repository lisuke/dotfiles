#!/bin/sh

theme=adw-gtk3
dark_mode=0
color_scheme=default
echo "gtk theme"

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

sed -i "s/gtk-theme=.*/gtk-theme=$theme/g" ~/.local/share/nwg-look/gsettings
sed -i "s/color-scheme=.*/color-scheme=$color_scheme/g" ~/.local/share/nwg-look/gsettings
nwg-look -x
