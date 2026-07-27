#!/usr/bin/env sh
hyprctl dispatch exec "[float; center; size 1024 768] ghostty --confirm-close-surface=false -e $*"
