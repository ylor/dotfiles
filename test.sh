npc() {
	str=$1
	while [ "$str" ]; do
		printf "%s" "${str%"${str#?}"}"
		sleep 0.01
		str=${str#?}
	done
}

clear
stty -echo -icanon time 0 min 1 # prevent ludonarrative dissonence
npc " ▲" && echo
npc "▲ ▲" && echo
npc "press any key to continue (or abort with ctrl+c)..."
dd bs=1 count=1 2>/dev/null
stty sane
