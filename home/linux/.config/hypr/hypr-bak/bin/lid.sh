#!/bin/env sh
if not hyprctl monitors | grep 'Monitor (DP|HDMI)'; then
    hyprlock && systemctl suspend
fi