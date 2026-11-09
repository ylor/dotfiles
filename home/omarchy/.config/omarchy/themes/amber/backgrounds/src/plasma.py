"""Re-render an image on an AmberConsole neon plasma panel: one lit cell per
pitch, the gaps between them the well.

Each cell is driven to a neon token level by the source's lightness, stretched
between the image's own --lo and --hi percentiles and spaced by the tokens' own
lightness (L*), so the near-black bottom tokens do not swallow the shadows.
Levels between two tokens come from ordered dithering across neighbouring
cells, the way a plasma panel's sub-fields drive the gas. Every output pixel is
a token. With --keep-color each cell is the source's own average color instead.

usage: python3 -I plasma.py SRC OUT [--keep-color] [--size 3840x2160]
       [--pitch 6] [--gap 2] [--gamma 1.0] [--lo 0.05] [--hi 0.99] [--value 0.25]
"""
import argparse
from PIL import Image, ImageDraw

WELL = (6, 2, 0)
# Unlit to hottest: screen, screen-raised, emit-30, -50, -70, -90, -100.
LADDER = [(16, 6, 0), (27, 12, 2), (91, 37, 0), (171, 69, 0), (221, 88, 0), (255, 107, 8), (255, 168, 109)]
BAYER4 = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]

ap = argparse.ArgumentParser()
ap.add_argument("src")
ap.add_argument("out")
ap.add_argument("--keep-color", action="store_true", help="cells in the source's own colors (for choosing art)")
ap.add_argument("--size", default="3840x2160")
ap.add_argument("--pitch", type=int, default=6)
ap.add_argument("--gap", type=int, default=2)
ap.add_argument("--gamma", type=float, default=1.0)
ap.add_argument("--lo", type=float, default=0.05)
ap.add_argument("--hi", type=float, default=0.99)
ap.add_argument("--value", type=float, default=0.25)
a = ap.parse_args()
W, H = map(int, a.size.split("x"))


def lin(c):
    c /= 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def lstar(rgb):
    y = 0.2126 * lin(rgb[0]) + 0.7152 * lin(rgb[1]) + 0.0722 * lin(rgb[2])
    return (y ** (1 / 3)) * 116 - 16 if y > 216 / 24389 else y * 24389 / 27


# Cover-crop to the output aspect, then sample one average color per cell.
im = Image.open(a.src).convert("RGB")
sw, sh = im.size
scale = max(W / sw, H / sh)
cw, ch = round(W / scale), round(H / scale)
im = im.crop(((sw - cw) // 2, (sh - ch) // 2, (sw - cw) // 2 + cw, (sh - ch) // 2 + ch))
gx, gy = W // a.pitch, H // a.pitch
px = list(im.resize((gx, gy), Image.LANCZOS).get_flattened_data())

if a.keep_color:
    colors = px
else:
    # Saturated light (sunset purples, magentas) reads dim in L*; blend in HSV
    # value so it still drives the cell, as the source's lit clouds do.
    L = [(1 - a.value) * lstar(p) / 100 + a.value * max(p) / 255 for p in px]
    s = sorted(L)
    lo, hi = s[int(a.lo * (len(s) - 1))], s[int(a.hi * (len(s) - 1))]
    if hi - lo < 0.02:
        # A mostly flat image (a logo on a plain ground): the percentiles
        # coincide, so fall back to its full span.
        lo, hi = s[0], max(s[-1], s[0] + 0.02)
    rung_l = [lstar(t) for t in LADDER]
    colors = []
    for k, v in enumerate(L):
        drive = min(1.0, max(0.0, (v - lo) / (hi - lo))) ** a.gamma
        want = rung_l[0] + drive * (rung_l[-1] - rung_l[0])
        r = 0
        while r < len(LADDER) - 2 and rung_l[r + 1] < want:
            r += 1
        frac = (want - rung_l[r]) / (rung_l[r + 1] - rung_l[r])
        i, j = k % gx, k // gx
        dither_up = frac > (BAYER4[j % 4][i % 4] + 0.5) / 16
        colors.append(LADDER[r + dither_up])

out = Image.new("RGB", (W, H), WELL)
d = ImageDraw.Draw(out)
cell = a.pitch - a.gap
for k, color in enumerate(colors):
    x0, y0 = (k % gx) * a.pitch, (k // gx) * a.pitch
    d.rectangle([x0, y0, x0 + cell - 1, y0 + cell - 1], fill=color)
out.save(a.out, optimize=True)
print(a.out)
