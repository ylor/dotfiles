#!/bin/sh
set -eu

# Disable input processing entirely (non-canonical mode)
stty -echo #-icanon time 0 min 1

# Function to display text with a typing effect
type() {
	echo $1 | while IFS="" read -r -n1 char; do
		printf "%s" "$char"
		sleep 0.01
	done
	sleep 0.5
}

clear
# Test output (text will be printed before any key can be pressed)
type "it's dangerous to go alone." && printf " " && type "take this!" && echo
type "press any key to continue (or abort with ctrl+c)..."

# Re-enable normal input behavior before waiting for a key press
while read -t 1 -n 1 dummy; do :; done
stty sane
# Wait for a key press to continue
read -n 1 -r -s
