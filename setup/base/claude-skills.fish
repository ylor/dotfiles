# Claude Code only reads ~/.claude/skills, so mirror .agents/skills into .claude/skills.
# The relink at the end of apply then layers them over whatever is already in ~/.claude/skills.
set claude $DOTFILES/home/base/.claude/skills

for source in $DOTFILES/home/base/.agents/skills/*/SKILL.md
    set name (path basename (path dirname $source))
    mkdir -p $claude/$name
    ln -sf ../../../.agents/skills/$name/SKILL.md $claude/$name/SKILL.md
end

# Drop mirrors whose skill was removed.
for link in $claude/*/SKILL.md
    test -e $link; and continue
    rm $link
    rmdir (path dirname $link) 2>/dev/null
end
