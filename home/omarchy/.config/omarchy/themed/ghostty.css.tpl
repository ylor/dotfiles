/* Omarchy renders this on every theme switch from colors.toml.
   Ghostty loads it above libadwaita's styles, so plain selectors win
   without repeating every state. */
:root {
  --bg: {{ background }};
  --fg: {{ foreground }};
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
   layout. Mixing in oklab keeps the steps even across themes. Bare tab
   selectors also match the dragged copy, which lives in dnd. */
tab {
  --ink: color-mix(in oklab, var(--fg) 85%, var(--bg));
  --line: color-mix(in oklab, var(--fg) 35%, var(--bg));
  min-height: 0;
  border-radius: 0;
  font-size: 0.85em;
  background: none;
  color: var(--ink);
  box-shadow: inset 0 0 0 1px var(--line);
  transition: color 120ms, box-shadow 120ms;
}

tab:hover {
  --ink: color-mix(in oklab, var(--fg) 95%, var(--bg));
  --line: color-mix(in oklab, var(--fg) 60%, var(--bg));
}

tab:selected {
  --ink: var(--fg);
  --line: var(--fg);
}

/* An unfocused window steps down so the focused one stands out. */
tab:backdrop {
  --ink: color-mix(in oklab, var(--fg) 70%, var(--bg));
}

tab:selected:backdrop {
  --ink: color-mix(in oklab, var(--fg) 80%, var(--bg));
  --line: color-mix(in oklab, var(--fg) 45%, var(--bg));
}

/* A dragged tab floats outside the bar, so it carries the bar's color. */
dnd tab {
  background-color: var(--bg);
}

tabbar button,
dnd button {
  min-height: 0;
  color: inherit;
  background: none;
  opacity: 0.7;
}

tabbar button:hover,
dnd button:hover {
  opacity: 1;
  background-color: color-mix(in oklab, var(--fg) 15%, transparent);
}

/* Progress bar from OSC 9;4. Libadwaita colors it with the system accent. */
.surface progressbar progress {
  background-color: var(--fg);
}

.surface progressbar.error progress {
  background-color: var(--red);
}
