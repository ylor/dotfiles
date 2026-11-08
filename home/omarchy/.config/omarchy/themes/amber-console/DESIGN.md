# Amber Console: design notes

This fork aims to make the Omarchy desktop read as one AmberConsole neon panel. Every neon token is used in the role AmberConsole gives it, and the theme ships no color outside the neon palette. This file records how each surface was decided, which source component it borrows from, and how the result was checked.

Sources used:

- **AmberConsole** pinned at `e616e1c`. `src/` is byte-identical on `main` (`1dd15b4`, 2026-11-06). The three commits since the pin don't touch `src/`, so the neon block in `src/tokens/colors.css` is unchanged.
- **Omarchy** `d9cc361` (the installed 4.0.0 package and upstream `main` on 2026-11-08). Key names come from `default/themed/*.tpl`, `bin/omarchy-theme-set-templates`, and the shell's `Commons/Color.qml`, `Commons/Style.qml` and `Commons/Border.qml`. None were guessed.

## The closed palette

| Token | Value | Source role |
| --- | --- | --- |
| `--ac-screen` | `#100600` | base panel |
| `--ac-screen-raised` | `#1b0c02` | subtly lifted region |
| `--ac-screen-well` | `#060200` | recessed input wells, meter troughs |
| `--ac-emit-100` | `#ffa86d` | ink-bright / fill-bright |
| `--ac-emit-90` | `#ff6b08` | ink / fill / stroke |
| `--ac-emit-70` | `#dd5800` | ink-dim |
| `--ac-emit-50` | `#ab4500` | ink-faint / stroke-dim |
| `--ac-emit-30` | `#5b2500` | ink-trace, decorative only |
| `--ac-on-fill` | `#1e0c00` | text on any emit fill |
| `--ac-halo-1` | `255, 120, 30` | core halo, box glow |
| `--ac-halo-2` | `255, 109, 12` | mid halo |
| `--ac-halo-3` | `255, 102, 0` | deep / outermost halo |
| `--ac-halo-4` | `255, 140, 64` | pale halo, hot cores |
| scatter / spread | `1` / `1` | neon is the reference |

These rules hold throughout:

- **One hue.** Meaning is carried by drive level, inverse video, and the labels and symbols the apps already print.
- **Drive level picks the tier, not the name.** `ink-dim` is emit-70, but `stroke-dim` is emit-50. Borders use only the stroke tiers (emit-100 on hover/focus, emit-90, emit-50) or ink-trace. They never use emit-70, except for the focus ring, which the source draws in `ink-dim`.
- **Halos are light.** They appear only with alpha below 1, and only at alpha values that `effects.css` or `sim/plasma.css` give them: 0.32 and 0.07 (glow-box, outer and inset), 0.26 (mid text halo), 0.10 (outermost text halo), 0.20 (plasma 26px layer), and 0.75 (plasma hot core). Drive tiers (×0.70, ×0.41) are applied the way the source applies them. In shell keys they are written `#RRGGBBAA`, with the same alpha the `-alpha` companion key states.
- **Alpha on screen and screen-well only for scrims.** Menu, launcher and polkit backdrops are `screen-well` at 0.72, the source's `.ac-dialog::backdrop` opacity, recolored from black to the well.
- **No blending.** No `mix` template function, no two-token gradients, and no Omarchy default left in place where that default blends or names an off-palette color. See *Static overrides*.

## What was wrong before, verified

Each finding below was checked against the upstream copy (commit 1 of this fork) using the lint described in *Verification*.

| Finding | Evidence | Fix |
| --- | --- | --- |
| emit-30 and all four halos unused | Baseline lint: `emit-30 0 files`, `halo-1..4 0 files` | Every token now has at least one role (coverage table below). |
| `screen-raised` only as `lighter_background`; `on-fill` only in selection | Baseline lint listing | Raised: cursorlines and diff lines. On-fill: group tabs, btop row, menu cursor row, claude inverse text. |
| `muted` was emit-70 | `colors.toml`. Omarchy's templates use `muted` 194 times: ANSI 8, btop `inactive_fg`/`div_line`, aether's comments and borders, gum placeholders. | `muted` is now emit-50 (ink-faint). Dividers that have their own key are emit-30. |
| ANSI collapse | All six bright slots and red = yellow resolved to emit-100. Alacritty `search.matches` (yellow) and `focused_match` (red) were identical. | Deliberate 16-slot map (README). Match is emit-90, focused match emit-100. |
| Inverse video unused for meaning | Only `selection` used on-fill | See *Inverse video* below. |
| `shell.toml` incomplete | It lacked `[hyprland] [controls] [polkit] [lock] [image-picker] [spacing] [font]`. In `Color.qml`, missing polkit/lock keys fall back to `urgent` (= `red`) for errors and to `foreground`/`accent` for everything else. The lock placeholder falls back to foreground at 0.66. In `Style.qml`, missing `[controls]` falls back to the template defaults, where focus mirrors hover. | Complete `shell.toml`; see the decision below. |
| Focus mirrored hover | `Style.qml`: `focus-*` falls back to `hover-cursor-*` | Five distinct states (*Controls*). |
| No `hyprland.lua` | The template's inactive-border fallback is a gray with alpha, and the window shadow and group tab colors were left at Omarchy's black and white defaults. | `hyprland.lua` sets borders, groups, groupbar, shadow and `misc.background_color`. |
| No `unlock.png` / `preview-unlock.png` | Present in 22 of 23 bundled themes | Added: the Omarchy logo at emit-100, binary alpha. |
| IMAX photo off-palette | Photo | Kept. A token-only wallpaper is added and sorted first. |
| btop | Generated from ANSI keys. Troughs used `selection`, dividers used `muted`. | `btop.theme` override. |
| Blended templates | Baseline lint: 32 off-palette literals from `mix` template functions in claude.json, hermes.yaml, pi.json, t3code.json and vscode-theme.json | Static overrides. |

## `shell.toml`: one complete file

A theme's `shell.toml` **replaces** the generated one (`omarchy-theme-set-templates` skips a template whose output the theme ships). `shell.<section>.toml` files are instead spliced into the *generated* file, replacing whole sections.

The theme ships one complete `shell.toml`. The reasons:

1. **The closed palette holds no matter what upstream changes.** With per-section overrides, every section not overridden is rendered from Omarchy's template. A future template that adds a `mix` function to an untouched section, as `[lock] placeholder` already does today, would ship a blended color without anyone touching this theme. With a complete file, a key the theme leaves out falls back in `Color.qml` or `Style.qml` to the colors.toml foundations (`foreground`, `background`, `accent`, `urgent`, `muted`). All of those are tokens.
2. **Every color section needs overriding anyway.** Only `[spacing]` and `[font]` would be left to the template, and those hold no colors.

`[spacing]`, `[font]` and the bar sizes are copied unchanged from `shell.toml.tpl` at `d9cc361` (`scale = 1.0`, `scale-with-font = true`, `base-size = 12`, `size-horizontal = 26`, `size-vertical = 28`). The commented per-token overrides are left out, because they are comments. The trade-off is that a future template change to those defaults won't reach this theme. After an Omarchy update, diff the two files:

```bash
diff <(grep -v '^\s*#' /usr/share/omarchy/default/themed/shell.toml.tpl) <(grep -v '^\s*#' shell.toml)
```

`[launcher]` mirrors `[menu]`. As of `d9cc361` no shell code reads a `launcher.*` key, because the launcher draws with `[menu]`. The section is kept so the theme stays correct if that changes.

## Surfaces

### Bar: `components/statusbar.css`, `--line` variant
`screen` background, `emit-90` text, `active` (recording, updates, alerts) `emit-100`. The filled (inverse) status bar was rejected: panels derive slider troughs and selection fills from `bar.foreground`, and `on-fill` there would paint those flyouts dark on dark.

### Controls: `base/reset.css`, `components/button.css`, `components/input.css`
Omarchy draws a control's label and its fill from the same state color (`Button.qml`: `_selectedColor` for both). A filled state therefore hides its own label, so inverse video can't be expressed. The five states are told apart by drive level and ring alone:

| State | Fill | Border | Source |
| --- | --- | --- | --- |
| normal | none | 1px emit-50 | input idle: `stroke-dim` |
| hover / keyboard cursor | halo-1 @ 0.07 | 1px emit-100 | `:hover` border `ink-bright`, glow-box inset 0.07 |
| focus | halo-3 @ 0.10 | **2px emit-70** | `:focus-visible` 2px `ink-dim` ring, outermost halo spilling in |
| selected (latched) | emit-100 @ 0.11, label emit-100 | none | `aria-pressed`, lit at the trace drive tier (0.11) |
| pressed | halo-2 @ 0.26 | inherits hover | the strongest tint, mid halo at its own alpha |

Text selection in shell fields is halo-3 @ 0.20 (the plasma 26px layer). The source's selection is inverse video, but the shell pins selected text to the field's ink. The 0.20 tint is the brightest that keeps ink above 5.2:1.

### Popups (bar flyouts, OSD, dock): `components/panel.css`
`screen`, `emit-90` text, 2px `emit-90` stroke.

### Tooltips: `components/panel.css` `--dim`
`screen` at full alpha, `emit-90` text, `emit-50` stroke-dim. A tooltip is transient, secondary content.

### Notifications: `components/banner.css`, `components/meter.css`
2px `emit-90` stroke and `emit-90` text. `countdown` is the meter bar fill, `emit-90`. Critical notifications use `red` (emit-100) through the shell's `urgent`, so urgency climbs the ramp: low (shell dim) < normal emit-90 < critical emit-100.

### Menu and launcher: `components/dialog.css`, `components/table.css`
`screen` card, 2px `emit-90` stroke, `screen-well` scrim at 0.72. The cursor row is inverse video at **fill-bright**: `emit-100` fill, `on-fill` text, and a 2px edge of halo-4 @ 0.75 (the plasma hot core, `sim/plasma.css`). Fill-bright rather than fill is used because the menu row is Omarchy's keyboard cursor, a hover state, and the source draws a latched element under hover in `--ac-fill-bright` (`button.css [aria-pressed]:hover`). It also keeps the 52%-opacity subtitle faintly visible. On an emit-90 fill it would vanish (see *Limits*).

### Polkit: `components/dialog.css`, `components/input.css`
A dialog: `emit-90` stroke and text, `screen-well` scrim at 0.72, and an `emit-100` lock glyph. On failure, text and border drive up to `emit-100` while the shell flashes the border, which supplies the blink half of the source's alarm. Polkit has no key for an error fill, so inverse video isn't possible.

### Lock screen: `components/input.css`
The input is a well: `screen-well` at full alpha, operator text `emit-100`, placeholder `emit-50`. The border is `emit-50` at rest, `emit-90` while typing, and `emit-100` on error, when the error message replaces the placeholder in `emit-100`. Selection is halo-4 @ 0.31 (hot core × faint tier) behind `emit-100` text.

### Image picker
Text `emit-90`, selected slice `emit-100`, unselected slices `emit-50` at full alpha. Omarchy's default is foreground at 0.28, an ink-with-alpha blend.

### Hyprland: `components/panel.css`, `components/tabs.css`, `tokens/effects.css`
- Focused window: `emit-100` border plus `--ac-glow-box` as the shadow: halo-1 @ 0.32, range 8 (8px × spread 1), render power 3. Hyprland takes a single shadow layer, so the 10px inset layer is dropped.
- Unfocused windows: `emit-50` border (`.ac-panel--dim`). At 2px, emit-30 drops below the 3:1 non-text gate (1.63:1) and the border disappears. Their glow is the faint tier, halo-1 @ 0.13.
- Groups: borders follow the same rule. Groupbar tabs follow `tabs.css`: the selected tab is latched, so it's inverse video (`emit-90` fill, `on-fill` text) and the others are `emit-90` ink on `screen`. A locked group drives its latched tab to `emit-100` and recesses the rest into `screen-well`.
- A window that can't join a group: `emit-30` (the source's disabled border), or `emit-70` when focused.
- `misc.background_color` is `screen`. Omarchy's default is black.

### Terminals (alacritty, kitty, ghostty, foot)
These come from the generated templates through `colors.toml`; see the ANSI map in the README. Selection is `emit-90` / `on-fill`. The cursor is `emit-100`. Search matches use `yellow` (emit-90) and the focused match `red` (emit-100), and the footer bar is `emit-90`. All of them carry `background` text, because the templates bind it that way.

The theme deliberately ships **no terminal configs**. The dotfiles deploy every file as a symlink, and Omarchy's glass mode (`omarchy-theme-set-glass`) appends its opacity block with `>>`. For `alacritty.toml`, `kitty.conf` and `ghostty.conf`, that append would write through the symlink into this repository. The generated files are regular files and are safe.

### btop: `components/meter.css`, `components/table.css`
Boxes `emit-50` (stroke-dim, every btop box is a read-only monitor), dividers `emit-30`, troughs (`meter_bg`) `screen-well`, inactive text `emit-50`, and the selected row in inverse video. Every graph climbs `emit-30 → emit-70 → emit-100` (start, mid, end). `main_bg` is empty, which means the terminal's own `screen`. It **must** stay empty: glass mode looks for exactly that line and otherwise appends to this file through its symlink.

### Neovim (aether.nvim), VS Code, Chromium, helix and the rest
These are generated from `colors.toml`. In neovim, `muted` (comments, borders, inlay hints) is now `emit-50`, `lighter_bg` (cursorline) is `screen-raised`, and `brown` (escape sequences) is `emit-70`. VS Code numbers and constants are `orange` = `emit-100`. Chromium's frame is `screen`.

### Static overrides
Six files replace generated ones. Each holds the template's own rendering, with only the blended keys reassigned:

| File | Reassigned keys |
| --- | --- |
| `btop.theme` | all (designed; see above) |
| `claude.json` | shimmer variants → the neighboring stop; `inactive` emit-50; diff lines raised (added) / well (removed), with word highlights in the opposite surface; message backgrounds raised or well; `rate_limit_empty` well; `inverseText` on-fill |
| `hermes.yaml` | `diff_added` raised, `diff_removed` well |
| `pi.json` | panels raised/well, `border` emit-50, `borderMuted` emit-30, `mutedText` emit-70, `dimText` emit-50 |
| `t3code.json` | row hover raised, row active screen, `error` emit-100, `warning` emit-90 |
| `vscode-theme.json` | `editor.lineHighlightBackground` raised, `editor.lineHighlightBorder` emit-30 |

Their drawback is drift. A key Omarchy adds to those templates later won't appear here until the files are regenerated from a fresh render.

## Coverage

Every token is used at least once in what the theme ships. The palette lint lists the staged files that contain each one.

| Token | Where | Role |
| --- | --- | --- |
| `screen` | colors `background`; every shell surface; terminals; btop (via terminal); chromium; wallpaper ground | base panel |
| `screen-raised` | colors `lighter_background` (helix and nvim cursorline, share-picker cards); claude/pi/hermes added-diff and message panels; t3code row hover; vscode line highlight; wallpaper unlit cells | lifted region |
| `screen-well` | colors `dark_background`; lock input; shell scrims (0.72); btop `meter_bg`; claude `rate_limit_empty`, removed-diff lines; pi user messages; groupbar locked-inactive; preview-unlock input | recessed well / trough |
| `emit-100` | `accent`, cursor, `red`, bright slots; active window border; bar `active`; menu cursor row fill; lock input text; control hover/selected; btop graph tops; unlock logo; wallpaper beam head | ink-bright / fill-bright |
| `emit-90` | `foreground`, selection fill; dialog, panel and notification strokes; countdown; groupbar active fill; btop selected row | ink / fill / stroke |
| `emit-70` | `dark_foreground`, green/cyan/blue; control focus ring; btop graph mid, proc misc; nogroup-active border; wallpaper legend | ink-dim |
| `emit-50` | `muted`, ANSI 8; inactive window border; tooltip stroke; control normal border; lock idle border and placeholder; image-picker unselected; btop boxes; wallpaper axes and halo ring | ink-faint / stroke-dim |
| `emit-30` | btop `div_line` and graph floors; pi `borderMuted`; vscode line-highlight border; nogroup border; wallpaper graticule and outer halo ring | ink-trace, never text |
| `on-fill` | `selection_foreground`; menu cursor-row text; groupbar active text; btop `selected_fg`; claude `inverseText` | inverse video |
| `halo-1` | window glow 0.32 / faint 0.13; control hover 0.07 | box glow |
| `halo-2` | control pressed 0.26 | mid halo |
| `halo-3` | control focus spill 0.10; text selection 0.20 | outer halo |
| `halo-4` | menu cursor-row edge 0.75; lock selection 0.31 | hot core |
| scatter / spread | window glow range 8 = 8px × 1 | neon reference, unscaled |

## Contrast

All figures are WCAG ratios. Tinted grounds are composited over the surface they sit on.

| Pair | Ratio | Gate |
| --- | --- | --- |
| emit-90 on screen (body) | 7.02 | ≥ 5.2 |
| emit-70 on screen (secondary) | 5.22 | ≥ 5.2 |
| emit-100 on screen | 10.57 | ≥ 5.2 |
| emit-50 on screen (faint and disabled only) | 3.42 | ≥ 3.0 |
| emit-100 in the lock well / emit-50 placeholder | 10.89 / 3.52 | 5.2 / 3.0 |
| emit-90 on raised / on well | 6.69 / 7.24 | ≥ 5.2 |
| on-fill on emit-90 | 6.64 | ≥ 4.5 |
| on-fill on emit-100 | 10.00 | ≥ 4.5 |
| screen on emit-100 / emit-90 (terminal cursor, search, footer) | 10.57 / 7.02 | ≥ 4.5 |
| emit-90 on hover (halo-1 0.07) / focus (halo-3 0.10) | 6.52 / 6.32 | ≥ 5.2 |
| emit-100 on selected (emit-100 0.11) | 8.97 | ≥ 5.2 |
| emit-90 on pressed (halo-2 0.26), momentary | 4.77 | ≥ 4.5 |
| emit-90 on text selection (halo-3 0.20) | 5.42 | ≥ 5.2 |
| emit-100 on lock selection (halo-4 0.31 over well) | 6.32 | ≥ 5.2 |
| emit-70 on raised (strings on a cursorline or diff line) | 4.97 | ≥ 4.5 only |
| menu subtitle on the cursor row (emit-90 at 52% over emit-100) | 1.25 | not text-grade; see *Limits* |

emit-30 is never assigned to a text key. No ANSI slot uses it, and none of the static overrides do.

## Verification

All of these ran in a scratch directory outside the dotfiles.

1. **Palette lint.** The lint copies the theme into a throwaway `HOME` and runs Omarchy's own `omarchy-theme-set-templates` with glass mode on and off. That renders every system and user template and merges theme files and any `shell.<section>.toml`. The lint then extracts every `#hex`, `rgb()`, `rgba()`, `0x` and bare `r,g,b` triple, plus named colors, from every staged text file. It fails on anything outside the 14 tokens after alpha is removed, and on any halo without alpha below 1. Result: **pass**, 34 staged files. Negative test: an opaque halo, Omarchy's gray border default, a blended `claude.json`, a stray triple and one bad wallpaper pixel each fail it.
2. **Pixel check.** Every non-transparent pixel of `backgrounds/00-amber-graticule.png`, `unlock.png` and `preview-unlock.png` is one of the nine opaque tokens, with no partial alpha. Result: **pass**. The graticule uses 7 tokens, preview-unlock 4, and unlock 1.
3. **Contrast.** The table above: **pass** on every gate listed.
4. **Applied live.** After `omarchy theme set amber-console`, `hyprctl getoption` reported: active border emit-100, inactive emit-50, groupbar active fill emit-90 with on-fill text, nogroup border emit-30, and background emit `screen`. Screenshots taken: bar, window borders, notification, menu (inverse cursor row, well scrim), terminal ANSI table, btop and the image picker. Not screenshotted: lock and polkit (they need a real lock or auth prompt), tooltips and bar popups (they need pointer hover or clicks), VS Code and Chromium. For those, the rendered files are the evidence.

## Limits (outside what a theme can set)

- **Shell-derived colors.** The shell computes some colors itself. Notification body and dim text are `Qt.darker(text, 1.15 / 1.4)`, the unchecked toggle knob is `Qt.darker(foreground, 1.25)`, and polkit text selection is `accent` at a fixed 0.45. None of them can be set from a theme.
- **Menu subtitles.** The shell draws them in `menu.text` at a fixed 52% opacity, even on the cursor row. Over the fill-bright row they are faint, at 1.25:1. Over an emit-90 row they would vanish. No on-palette key changes that.
- **aether.nvim** blends some backgrounds at runtime (`Util.blend_bg`). **btop** interpolates between its start, mid and end stops. Each named stop is a token, but the cells in between are blends.
- **SDDM.** Its failed-login assets are recolored by `omarchy-plymouth-set` to a hard-coded red.
- **Plymouth refuses symlinks.** `omarchy-plymouth-set` rejects a symlinked logo, and the dotfiles deploy `unlock.png` as a symlink, so `omarchy-plymouth-set-by-theme amber-console` won't take it. To apply it, pass the dotfiles path directly: `omarchy-plymouth-set '#100600' '#ff6b08' <dotfiles>/home/omarchy/.config/omarchy/themes/amber-console/unlock.png`.
- **btop's own config chooses its theme.** `btop.theme` is used only when `btop.conf` sets `color_theme` to the current Omarchy theme. With `color_theme = "TTY"`, btop draws from the 16-slot ANSI map instead. That is still on-palette, but it has no screen-well troughs or emit-30 dividers.
- **The user's global Hyprland config** (`hypr/looknfeel.lua`, `dim_inactive`, the animations-off toggle) loads after the theme. It replaces the window glow with its own `screen-well` shadow, dims inactive windows toward black, and currently disables shadows altogether. None of that is changed here.
