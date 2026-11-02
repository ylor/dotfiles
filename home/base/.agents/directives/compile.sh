#!/bin/sh
# Join the numbered directives into ../AGENTS.md, one "# NAME" section per file.
cd "$(dirname "$0")" || exit 1

sep=
for file in *.md; do
    name=${file#*-}
    printf '%s# %s\n\n' "$sep" "${name%.md}"
    sed 's/[[:blank:]]*$//' "$file"
    sep='
'
done > ../AGENTS.md
