- Routine runs should not require sudo
- Do not ask for sudo unless it's actually needed
- If sudo is needed, only ask for it once in the entire run
- Do not create bak files, this is a git repo and history is tracked

- After creating or deleting (not editing) a file or folder inside @home/ run `fish $DOTFILES/main.fish link` at the end of the turn.
