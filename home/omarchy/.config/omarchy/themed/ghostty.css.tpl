/* Omarchy renders this on every theme switch from colors.toml.
   Ghostty loads it above libadwaita's styles, so plain selectors win
   without repeating every state. */
:root {
  --bg: {{ background }};
  --bright: {{ bright_foreground }};
  --fg: {{ foreground }};
  --dim: {{ dark_foreground }};
  --faint: {{ muted }};
  --trace: {{ selection }};
  --red: {{ red }};
}

/* windowhandle sits inside headerbar and tabbar, so painting it too would
   stack two translucent layers and darken the bar. */
windowhandle {
  background: none;
}

headerbar,
tabbar .box {
  min-height: 0;
  background-color: var(--bg);
  color: var(--fg);
  box-shadow: none;
  border: none;
}

/* Ghostty drops .background when background-opacity is below 1. CSS cannot
   read the value, so this repeats omarchy glass's 0.65. */
window:not(.background) headerbar,
window:not(.background) tabbar .box {
  background-color: rgb(from var(--bg) r g b / 0.65);
}

/* Libadwaita draws a line under the bar and between tabs. */
toolbarview > .top-bar,
toolbarview scrolledwindow > undershoot.top,
tabbar separator {
  box-shadow: none;
  background: none;
}

/* Libadwaita fades bars to half opacity in unfocused windows. */
tabbar .box > scrolledwindow,
tabbar .box > .start-action,
tabbar .box > .end-action,
headerbar > windowhandle,
toolbarview > .top-bar > windowhandle {
  filter: none;
}

tabbar tabboxchild {
  border-radius: 0;
}

/* Tabs show the bar's glass. An inset outline marks state without shifting
   layout. Each state takes a palette key rather than a mix, so a theme with a
   strict palette stays on it. Bare tab selectors also match the dragged copy,
   which lives in dnd. */
tab {
  --ink: var(--faint);
  --line: var(--trace);
  min-height: 0;
  border-radius: 0;
  font-size: 0.85em;
  background: none;
  color: var(--ink);
  box-shadow: inset 0 0 0 1px var(--line);
}

tab:hover {
  --ink: var(--bright);
  --line: var(--bright);
}

tab:selected {
  --ink: var(--fg);
  --line: var(--fg);
}

/* An unfocused window steps down so the focused one stands out. */
tab:backdrop {
  --ink: var(--faint);
}

tab:selected:backdrop {
  --ink: var(--dim);
  --line: var(--faint);
}

/* A dragged tab floats outside the bar, so it carries the bar's color. */
dnd tab {
  background-color: var(--bg);
}

tabbar button,
dnd button {
  min-height: 0;
  color: var(--dim);
  background: none;
}

tabbar button:hover,
dnd button:hover {
  color: var(--bright);
  background-color: var(--trace);
}

/* Progress bar from OSC 9;4. Libadwaita colors it with the system accent. */
.surface progressbar progress {
  background-color: var(--fg);
}

.surface progressbar.error progress {
  background-color: var(--red);
}
