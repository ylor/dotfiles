#!/usr/bin/env sh
# hyprctl dispatch exec "[float; center] $*"
hyprctl dispatch exec "[float; size 40% 60%; center] ghostty --confirm-close-surface=false -e $*"