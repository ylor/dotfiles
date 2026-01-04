#!/usr/bin/env bash
qs -c noctalia-shell ipc call launcher clipboard

wl-copy --clear
timeout 60s bash -c 'until wl-paste; do sleep 0.1; done'

sleep 0.2
hyprctl dispatch sendshortcut "CTRL SHIFT,V,"