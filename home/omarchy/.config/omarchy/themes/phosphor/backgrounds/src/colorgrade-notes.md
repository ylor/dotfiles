# Sunset grade — pending approval

Sources remain unchanged. Outputs are ../1-quattro.webp and ../2-toyota.webp; 3-black.webp is untouched.

First review version: replace purple/magenta with warm copper/orange, deepen midtones, and lower highlights for a dark room. No resize, crop, or sharpening.

Exact operation for each source (ImageMagick 7.1.2-31 Q16-HDRI):

```sh
magick "$source" \
  -color-matrix '1 0 0 0.32 0.60 0 0.08 0.32 0.25' \
  -gamma 0.85 \
  -evaluate Multiply 0.72 \
  -define webp:lossless=true "$output"
```

Matrix operates on encoded sRGB channels: R'=R, G'=0.32R+0.60G, B'=0.08R+0.32G+0.25B. Gamma deepens midtones; final multiplier caps channel values at approximately 184/255. Lossless WebP avoids another lossy compression pass. Original dimensions preserved.

Write the recreation script only after user approval; update these notes with any subsequent adjustments.

## P3 amber alternative — pending approval

Outputs: ../1-quattro-p3.webp and ../2-toyota-p3.webp. Created directly from the original sources, not the sunset grades. Existing outputs remain unchanged.

Revised per user clarification: P3 means the theme accent, #d97706 (colors.toml), not a generic phosphor approximation. The initial #c28e35 version was rejected and replaced. Monochrome accent color only: no glow, scanlines, grain, or other CRT effects. Map source Rec.709 luma to black–#d97706, with gamma 0.90 to deepen midtones.

```sh
magick "$source" \
  -grayscale Rec709Luma \
  -gamma 0.90 \
  +level-colors '#000000','#d97706' \
  -define webp:lossless=true "$output"
```

Same ImageMagick version, original dimensions, lossless WebP encoding.


## P3 revision 3 — restore depth (pending approval)

User rejected monochrome revisions for flattening contrast and depth. Current *-p3.webp outputs now preserve RGB variation directly from sources. Amber is a palette reference, not an exact monochrome endpoint. Red-orange clouds/dust, golden highlights, and subdued near-neutral shadows retain separation. No spatial effects.

Exact current command (same ImageMagick version):

```sh
magick "$source" \
  -color-matrix '1 0 0 0.26 0.50 0 0.02 0.10 0.35' \
  -gamma 0.95 \
  -evaluate Multiply 0.78 \
  -define webp:lossless=true "$output"
```

Replaces the monochrome recipe above for P3 outputs; sunset outputs remain unchanged.
