#!/bin/sh

content=$(
    for file in *.md; do
        name=${file#*-}
        printf '# %s\n\n' "${name%.md}"
        sed 's/[[:blank:]]*$//' "$file"
        printf '\n'
    done
)

printf '%s\n' "$content" > ../AGENTS.md
