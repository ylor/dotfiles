#!/bin/bash

type() {
	echo $1 | while IFS="" read -r -n1 char; do
		printf "%s" "$char"
		sleep 0.01
	done
	sleep 0.5
}

clear
type "hey..." && echo
type "hey listen!" && echo
type "it's dangerous to go alone." && printf " " && type "take this!" && echo
type "press any key to continue (or abort with ctrl+c)..." && read -n 1 -r -s
