#!/usr/bin/env bash
# Populate amber's backgrounds from every stock Omarchy theme.
#
# Each kept image is rendered twice on the plasma cell matrix (plasma.py):
#   x-<theme>-<name>.png        in the source's own colors (for choosing)
#   x-<theme>-<name>-amber.png  driven onto the AmberConsole neon tokens
#
# Skipped: byte-identical duplicates, logo wallpapers, bright (light-theme)
# images, and the names in SKIP below. Existing x-*.png files are replaced.
#
# usage: populate.sh [--dry-run]
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
out=$(dirname "$here")
themes=${OMARCHY_PATH:-/usr/share/omarchy}/themes

# Logo wallpapers: anything named omarchy, and the bare oma mark.
LOGO='(^|-)omarchy|^7-oma$'
# Mean CIE L* (0-1) at or above which an image counts as bright.
BRIGHT=0.6
# Matched against "<theme>/<name>".
SKIP='^catppuccin/|roadster|blink|^miasma/|omakub'

render() {
  local f=$1 theme name
  theme=$(basename "$(dirname "$(dirname "$f")")")
  name=$(basename "${f%.*}")
  python3 -I "$here/plasma.py" "$f" "$out/x-$theme-$name.png" --keep-color >/dev/null
  python3 -I "$here/plasma.py" "$f" "$out/x-$theme-$name-amber.png" >/dev/null
  echo "rendered $theme/$name"
}

keep=()
total=0
# One path per distinct image: the first by path among byte-identical copies.
while IFS= read -r f; do
  total=$((total + 1))
  theme=$(basename "$(dirname "$(dirname "$f")")")
  name=$(basename "${f%.*}")
  if [[ $name =~ $LOGO ]]; then
    echo "skip logo    $theme/$name"
    continue
  fi
  if [[ "$theme/$name" =~ $SKIP ]]; then
    echo "skip listed  $theme/$name"
    continue
  fi
  lightness=$(magick "$f" -resize 400x -colorspace Lab -channel R -separate -format '%[fx:mean]' info: 2>/dev/null)
  if awk -v l="$lightness" -v t="$BRIGHT" 'BEGIN { exit !(l >= t) }'; then
    echo "skip bright  $theme/$name ($lightness)"
    continue
  fi
  keep+=("$f")
done < <(find "$themes"/*/backgrounds -maxdepth 1 -type f \( -name '*.webp' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.png' \) -print0 |
  xargs -0 sha256sum | sort -k2 | awk '!seen[$1]++ { print $2 }')

echo "keep ${#keep[@]} of $total"
[[ ${1:-} == --dry-run ]] && exit 0

rm -f "$out"/x-*.png
export here out
export -f render
printf '%s\0' "${keep[@]}" | xargs -0 -P "$(nproc)" -n1 bash -c 'render "$1"' _
