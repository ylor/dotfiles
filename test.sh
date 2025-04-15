npc() {
	echo $1 | while IFS="" read -r -n1 char; do
		printf "%s" "$char"
		sleep 0.01
	done
	sleep 0.5
}

clear
stty -echo -icanon time 0 min 1 # block user input
npc "hey..." && echo
npc "hey listen!" && echo
npc "it's dangerous to go alone." && printf " " && npc "take this!" && echo
npc "press any key to continue (or abort with ctrl+c)..."
stty sane # allow user input
read -t 1 -r -s # munch buffered keypresses
read -n 1 -r -s # prompt

brew list
