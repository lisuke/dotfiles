#!/bin/sh


# pactl

pactl_mute() {
    muted=`expr "$(pactl get-sink-mute @DEFAULT_SINK@)" : "Mute: \(.*\)"`
    if [[ $muted == "yes" ]]; then
        pactl set-sink-mute @DEFAULT_SINK@ 0
        notify-send -a "VOLUME" "UNMUTED" -i audio-volume-high -r 2593 -u normal
    else
        pactl set-sink-mute @DEFAULT_SINK@ 1
        notify-send -a "VOLUME" "MUTED" -i audio-volume-muted -r 2593 -u normal
    fi
    canberra-gtk-play -i audio-volume-change -d "changevolume"
}

pactl_dec() {
    pactl set-sink-volume @DEFAULT_SINK@ -2%
    volume=`expr "$(pactl get-sink-volume @DEFAULT_SINK@)" : '.*\/*\(..[0-9]\)%'`
    notify-send -a "VOLUME" "Decreasing to $volume%" -h int:value:"$volume" -i audio-volume-low -r 2593 -u normal
    canberra-gtk-play -i audio-volume-change -d "changevolume"
}

pactl_inc() {
    pactl set-sink-volume @DEFAULT_SINK@ +2%
    volume=`expr "$(pactl get-sink-volume @DEFAULT_SINK@)" : '.*\/*\(..[0-9]\)%'`
    notify-send -a "VOLUME" "Increasing to $volume%" -h int:value:"$volume" -i audio-volume-high -r 2593 -u normal
    canberra-gtk-play -i audio-volume-change -d "changevolume"
}



# wpctl

wpctl_inc() {
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%+
    volume=`expr "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)" : 'Volume: \([0-9,.]*\)'`
    volume=`awk 'BEGIN{print "'$volume'" * 100}'`
    dunstify -a "VOLUME" "Increasing to $volume%" -h int:value:"$volume" -i audio-volume-high -r 2593 -u normal
    canberra-gtk-play -i audio-volume-change -d "changevolume"
}

wpctl_dec() {
    wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 2%-
    volume=`expr "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)" : 'Volume: \([0-9,.]*\)'`
    volume=`awk 'BEGIN{print "'$volume'" * 100}'`
    dunstify -a "VOLUME" "Decreasing to $volume%" -h int:value:"$volume" -i audio-volume-low -r 2593 -u normal
    canberra-gtk-play -i audio-volume-change -d "changevolume"
}

wpctl_mute() {
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    if [[ "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)" == *MUTED* ]]; then
        dunstify -a "VOLUME" "MUTED" -i audio-volume-muted -r 2593 -u normal
    else
        dunstify -a "VOLUME" "UNMUTED" -i audio-volume-high -r 2593 -u normal
    fi
    canberra-gtk-play -i audio-volume-change -d "changevolume"
}


if [[ $1 == "pactl" ]]; then
    case "$2" in
        inc)    pactl_inc;;
        dec)    pactl_dec;;
        mute)   pactl_mute;;
    esac
elif [[ $1 == "wpctl" ]]; then
    case "$2" in
        inc)    wpctl_inc;;
        dec)    wpctl_dec;;
        mute)   wpctl_mute;;
    esac
else
    echo "args: [pactl|wpctl] [inc|dec|mute]"
fi
