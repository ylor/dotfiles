#!/usr/bin/env bash
# Grade src/* into ../<name>.webp for the phosphor theme.
# Works in LCh: lightness is never touched, so contrast and depth stay as in the source.
# Warm hues move into the theme's amber/crimson range. Blues and violets keep a cool hue
# at low chroma, which keeps the warm/cool separation that gives the images depth.
set -euo pipefail

src_dir=$(cd "$(dirname "$0")" && pwd)
out_dir=$(dirname "$src_dir")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Piecewise-linear lookup over source hue (0-360 deg), written as a 3600x1 PGM.
lut() {
  awk -v xs="$1" -v ys="$2" -v scale="$3" 'BEGIN {
    n = split(xs, x, " "); split(ys, y, " ")
    printf "P2\n3600 1\n65535\n"
    for (i = 0; i < 3600; i++) {
      h = i / 10
      for (k = 1; k < n; k++) if (h >= x[k] && h <= x[k+1]) {
        t = (h - x[k]) / (x[k+1] - x[k]); v = y[k] + t * (y[k+1] - y[k]); break
      }
      if (scale == 360) v = v % 360
      printf "%d ", v / scale * 65535
    }
    print ""
  }'
}

# source hue -> target hue
lut "0 30 70 100 140 180 180.01 250 300 315 335 360" \
    "45 55 68 86 92 95 250 270 290 300 390 405" 360 > "$tmp/hue.pgm"
# source hue -> chroma multiplier
lut "0 180 200 300 315 335 360" \
    "1 1 0.4 0.35 0.45 0.9 1" 1 > "$tmp/chroma.pgm"

for src in "$src_dir"/*.{webp,jpg,jpeg,png}; do
  [ -e "$src" ] || continue
  name=$(basename "${src%.*}")
  out="$out_dir/$name.webp"
  echo "grading $src -> $out"
  # ImageMagick stores LCh chroma offset around 0.5, so scale it around that point.
  magick "$src" -colorspace LCHab -separate \
    \( -clone 2 "$tmp/chroma.pgm" -interpolate integer -clut \) \
    \( -clone 1 -evaluate subtract 50% -clone 3 -compose multiply -composite -evaluate add 50% \) \
    \( -clone 2 "$tmp/hue.pgm" -interpolate integer -clut \) \
    -delete 1-3 -set colorspace LCHab -combine -colorspace sRGB \
    -define webp:lossless=true "$out"
done
