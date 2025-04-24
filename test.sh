if [ -x "$(command -v tput)" ]; then
	RESET="$(tput sgr0)"
	BOLD="$(tput bold)"
	RED="$(tput setaf 1)"
	GREEN="$(tput setaf 2)"
	BLUE="$(tput setaf 4)"
	CLEAR_LINE="$(tput el)"
else
	RESET="" BOLD="" RED="" GREEN="" BLUE="" CLEAR_LINE=""
fi

info() {
  # Print without newline, keep cursor on the same line
  printf "\r${BOLD}${BLUE}INFO${RESET} %s" "$*"
}

error() {
  # Overwrite line with error message
  printf "\r${BOLD}${RED}ERROR${RESET} %s${CLEAR_LINE}\n" "$*" && exit 1
}

success() {
  # Overwrite line with success message
  printf "\r${BOLD}${GREEN}SUCCESS${RESET} %s${CLEAR_LINE}\n" "$*"
}

info "Linking dotfiles..."
sleep 1
success "Linked!"
