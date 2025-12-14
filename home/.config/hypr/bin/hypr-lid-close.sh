#!/bin/env sh
if hyprctl monitors | grep 'Monitor (DP|HDMI)'; then
    hyprlock && systemctl suspend
fi