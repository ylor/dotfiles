#!/usr/bin/env bash
initial=$(wl-paste)

qs -c noctalia-shell ipc call launcher clipboard 
while [ "$initial" = "$(wl-paste)" ]; do
    sleep 0.25
done

# sleep 0.1
hyprctl dispatch sendshortcut "CTRL SHIFT,V,"