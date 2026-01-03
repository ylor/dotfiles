#!/usr/bin/env sh
hyprctl dispatch exec "[float; center; size 800 600] ghostty --confirm-close-surface=false -e $*"
