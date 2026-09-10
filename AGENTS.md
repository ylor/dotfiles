- Routine runs should not require sudo
- Do not ask for sudo unless it's actually needed
- If sudo is needed, only ask for it once in the entire run
- Do not create bak files, this is a git repo and history is tracked through git.
- Make configuration changes in this dotfiles repository, not directly in the live system.
- Place new or changed configuration at the appropriate project layer. If the correct layer is unclear or confidence is low, ask before editing.

- After creating or deleting (not editing) a file or folder inside @home/ run `fish $DOTFILES/main.fish link` at the end of the turn.
