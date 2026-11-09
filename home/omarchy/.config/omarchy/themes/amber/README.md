# Amber (personal fork)

An adaptation of [DutchDiederik](https://github.com/DutchDiederik)'s
[AmberConsole](https://github.com/DutchDiederik/AmberConsole).

This theme has one rule: **every color is a token from the plasma / neon block of
AmberConsole's `src/tokens/colors.css`.** No template mixes, no stray hues, no
photographs.

## Tokens and where they go

| Token | Hex | Desktop role |
| --- | --- | --- |
| screen | `#100600` | every surface: bar, panels, menus, terminals |
| screen-raised | `#1b0c02` | lifted rows: current line, user messages, added-diff lines |
| screen-well | `#060200` | recessed: tooltips, code blocks, sidebars, scrims, removed-diff lines |
| emit-100 | `#ffa86d` | focus and hover outlines, cursors, headings, alarms (errors, warnings) |
| emit-90 | `#ff6b08` | body text, panel strokes, focused window border, inverse-video fills |
| emit-70 | `#dd5800` | secondary text, strings/types/dirs, success |
| emit-50 | `#ab4500` | placeholders, comments, idle control outlines, read-only panes (btop) |
| emit-30 | `#5b2500` | inactive window border, selection cells, dotted leaders, slider tracks |
| on-fill | `#1e0c00` | text on a fill: selected menu row, selected process, terminal selection |

The halo-1..4 glow triples have no consumer: nothing on the desktop draws the
source's glow, and a floating-window glow was tried and dropped.

## Design rules, taken from the source components

- **One emitter, five drive levels.** ANSI names are roles: red and yellow are
  alarms at emit-100; magenta and orange read at emit-90; green, cyan and blue
  are context at emit-70; brown and bright black are ghosts at emit-50. Each
  `bright_*` is one level above its partner.
- **Panels are strokes, not elevation.** Popups, menus, launcher, notifications
  and polkit draw a 2px emit-90 stroke on screen ("every stroke is 2px — no
  hairlines"). Read-only regions (btop boxes, tooltips) recede to stroke-dim.
- **Hover and focus light the outline** to ink-bright. Idle controls sit at
  stroke-dim.
- **Selection is inverse video** where the app swaps text color (launcher,
  btop, terminals: emit-90 fill, on-fill text). Where the app keeps its own
  text color (menus and omacast, shell controls, Claude, t3code, Obsidian)
  selection is an opaque trace cell with an ink-bright title, so ink stays
  readable and nothing blends off-palette.
- **No red, no green.** Errors run hottest; success stays calm at emit-70.
- **Opaque by default.** Alpha only where the compositor must see through a
  layer: scrims, the lock card, Ghostty's glass.
