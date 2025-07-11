#!/usr/bin/env sh

status=$(mpc status)
if grep "playing" <<< "$status" >/dev/null; then
    echo "󰎆  $(mpc status)"
else
    echo "󰎆  $(mpc stats)"
fi

echo "󱎫  $(uptime)"
