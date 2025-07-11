#!/usr/bin/env bash

# credits to mmsaeed509
# https://github.com/mmsaeed509/bspwm-dots

bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

# creating "dictionary" to replace char with bar
i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i=i+1))
done

# make sure to clean pipe
pipe_fifo_file="/tmp/cava.fifo"
if [ -p $pipe_fifo_file ]; then
    unlink $pipe_fifo_file
fi
mkfifo $pipe_fifo_file

# write cava config
waybar_cava_config_file="/tmp/waybar_cava_config"
echo "
[general]
bars = 250
[output]
method = raw
raw_target = $pipe_fifo_file
data_format = ascii
ascii_max_range = 7
" > $waybar_cava_config_file

# run cava in the background
cava -p $waybar_cava_config_file &

# reading data from fifo
while read -r cmd; do
    echo $cmd | sed $dict
done < $pipe_fifo_file
