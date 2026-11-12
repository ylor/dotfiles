# Alternate ramps: a more amber neon

The shipped theme uses AmberConsole's neon palette exactly, at HSL hue 24°.
That ink reads red-orange. This file records how to move it toward amber using
the same method the original ramp was built with, and the three hues tried.
None of them is applied. The theme still ships the 24° originals.

## How the neon ramp is built

AmberConsole's neon ramp is hand-built. It is not produced by
`scripts/derive-gas.mjs`. Reverse-engineered from the shipped values, the method
is:

1. **Hue is fixed at HSL 24°.** Every stop and every halo triple sits at
   24.0 ± 0.4°.
2. **Saturation is 100%.**
3. **Lightness is solved per stop** so that each stop hits a target WCAG
   contrast ratio against `--ac-screen` (`#100600`):

   | stop     | ratio | role                       |
   | -------- | ----- | -------------------------- |
   | emit-100 | 10.5  | hot highlight / focus      |
   | emit-90  | 7.0   | primary ink                |
   | emit-70  | 5.2   | secondary ink              |
   | emit-50  | 3.4   | dim; clears the 3:1 non-text gate |
   | emit-30  | 1.63  | trace, decorative          |

4. **`--ac-on-fill` is solved against emit-90**, at the shipped ratio of about
   6.66:1.
5. **Halos are not held to a contrast target.** They keep their HSL lightness
   at the new hue.

Running this at 24° reproduces the shipped ramp to within one step in one
channel (`#ff6b07` against `#ff6b08`). So moving toward amber means changing
only the hue and solving lightness again. Rotating the hue at a fixed lightness
is the "re-tint" that AmberConsole's RATIONALE.md warns against: a higher hue is
brighter at the same lightness, so the ratios would drift.

`RATIONALE.md` § Hue defends **19–31°** as the physically plausible range for a
pulsed neon cell, so 31° is the most amber this can go while still being "neon".
CRT P3 amber sits at about 38°.

The surfaces (`#100600`, `#1b0c02`, `#060200`) stay as they are. At near-black,
a few degrees of hue is lost in rounding, and every ratio below is measured
against the unchanged `#100600`.

## Results

| token              | 24° (shipped)      | 26°                | 28°                | 31°                |
| ------------------ | ------------------ | ------------------ | ------------------ | ------------------ |
| emit-100           | `#ffa86d` 10.57    | `#ffa865` 10.53    | `#ffa85c` 10.50    | `#ffa94c` 10.53    |
| emit-90            | `#ff6b08` 7.02     | `#fd6d00` 7.03     | `#f67300` 7.03     | `#ec7a00` 7.01     |
| emit-70            | `#dd5800` 5.22     | `#d75d00` 5.20     | `#d16200` 5.21     | `#c96800` 5.21     |
| emit-50            | `#ab4500` 3.42     | `#a74800` 3.41     | `#a24c00` 3.41     | `#9c5100` 3.43     |
| emit-30            | `#5b2500` 1.63     | `#592700` 1.64     | `#572800` 1.63     | `#532b00` 1.63     |
| on-fill            | `#1e0c00`          | `#1d0c00`          | `#1c0d00`          | `#1a0d00`          |
| halo-1             | `255, 120, 30`     | `255, 128, 30`     | `255, 135, 30`     | `255, 146, 30`     |
| halo-2             | `255, 109, 12`     | `255, 117, 12`     | `255, 125, 12`     | `255, 138, 12`     |
| halo-3             | `255, 102, 0`      | `255, 111, 0`      | `255, 119, 0`      | `255, 132, 0`      |
| halo-4             | `255, 140, 64`     | `255, 147, 64`     | `255, 153, 64`     | `255, 163, 64`     |
| chromium seed      | `30,12,0`          | `29,12,0`          | `28,13,0`          | `26,13,0`          |

The chromium seed is the on-fill color.

OKLab L for each emit stop, from emit-100 down to emit-30:

| hue | emit-100 | emit-90 | emit-70 | emit-50 | emit-30 |
| --- | -------- | ------- | ------- | ------- | ------- |
| 24° | .805     | .702    | .625    | .520    | .337    |
| 26° | .804     | .702    | .623    | .518    | .337    |
| 28° | .803     | .700    | .621    | .517    | .336    |
| 31° | .803     | .696    | .619    | .516    | .335    |

### Verdict

- **31°** was too yellow.
- **26°** was too subtle a change.
- **28°** was the preferred alternate.

One trade-off holds for all three. Because emit-90 stays at 7:1, a more amber
hue loses some red: the red channel is 255 at 24°, 253 at 26°, 246 at 28° and
236 at 31°. Keeping 255 red would mean letting the ratio rise above 7:1, as P3
does at 10.8:1, which breaks the neon contrast contract.

## Applying an alternate

Replace these values across `colors.toml`, `btop.theme`, `neovim.lua` and
`hyprland.lua`. Shown here for 28°:

| original  | 28°       | token                      |
| --------- | --------- | -------------------------- |
| `ffa86d`  | `ffa85c`  | emit-100                   |
| `ff6b08`  | `f67300`  | emit-90                    |
| `dd5800`  | `d16200`  | emit-70                    |
| `ab4500`  | `a24c00`  | emit-50                    |
| `5b2500`  | `572800`  | emit-30                    |
| `1e0c00`  | `1c0d00`  | on-fill                    |
| `ff781e`  | `ff871e`  | halo-1 (Hyprland shadow)   |
| `ff6600`  | `ff7700`  | halo-3 (Hyprland shadow)   |

Then set `chromium.theme` to `28,13,0`, update the ratio and OKLab L notes in
`colors.toml` and `README.md`, and run `omarchy-theme-set lumon-amber`.

Leave these unchanged: the surfaces, `bright_green #00964d`, and btop's
`#fc003a` alarm red.

The preview images would also need regenerating.

## Generator

Prints the ramp for any hue, solved against the shipped surfaces.
Usage: `node neonramp.mjs 28`.

```js
// Neon's hand-built method: fixed HSL hue, S=100%, L solved to a contrast ratio.
const lin = (u) => { u /= 255; return u <= 0.04045 ? u / 12.92 : ((u + 0.055) / 1.055) ** 2.4; };
const Yof = ([r, g, b]) => 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b);
const cr = (a, b) => (Math.max(a, b) + 0.05) / (Math.min(a, b) + 0.05);
const hsl = (h, s, l) => {
  const k = (n) => (n + h / 30) % 12, a = s * Math.min(l, 1 - l);
  const f = (n) => l - a * Math.max(-1, Math.min(k(n) - 3, 9 - k(n), 1));
  return [f(0), f(8), f(4)].map((v) => Math.round(v * 255));
};
const hex = (c) => "#" + c.map((v) => v.toString(16).padStart(2, "0")).join("");
const rgb = (h) => [1, 3, 5].map((i) => parseInt(h.slice(i, i + 2), 16));

// Bisect L, then take the nearest rounded color at or above the target.
const solveL = (h, f, target) => {
  let lo = 0, hi = 1;
  for (let i = 0; i < 50; i++) { const mid = (lo + hi) / 2; f(hsl(h, 1, mid)) < target ? (lo = mid) : (hi = mid); }
  let best = null;
  for (let d = -0.01; d <= 0.01; d += 0.0005) {
    const c = hsl(h, 1, hi + d);
    if (f(c) >= target && (!best || f(c) < f(best))) best = c;
  }
  return best;
};

const STOPS = [["100", 10.5], ["90", 7.0], ["70", 5.2], ["50", 3.4], ["30", 1.63]];
const HALOS = [[255, 120, 30], [255, 109, 12], [255, 102, 0], [255, 140, 64]];
const sY = Yof(rgb("#100600"));
const H = Number(process.argv[2] ?? 24);

let e90;
for (const [s, r] of STOPS) {
  const c = solveL(H, (x) => cr(Yof(x), sY), r);
  if (s === "90") e90 = c;
  console.log(`emit-${s}: ${hex(c)}  ${cr(Yof(c), sY).toFixed(2)}:1`);
}
const ofRatio = cr(Yof(rgb("#1e0c00")), Yof(rgb("#ff6b08")));
for (let l = 0.2; l > 0; l -= 0.0005) {
  const c = hsl(H, 1, l);
  if (cr(Yof(c), Yof(e90)) >= ofRatio) { console.log(`on-fill: ${hex(c)}`); break; }
}
HALOS.forEach((c, i) => {
  const l = (Math.max(...c) + Math.min(...c)) / 510;
  console.log(`halo-${i + 1}: ${hsl(H, 1, l).join(", ")}`);
});
```
