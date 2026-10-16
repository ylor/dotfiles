/* Omarchy renders this on every theme switch from colors.toml.
   Ghostty loads it above libadwaita's styles, so plain selectors win
   without repeating every state. */
:root {
  --bar-bg: {{ background }};
  --bar-fg: {{ foreground }};
  --theme-red: {{ red }};
}

/* windowhandle sits inside headerbar and tabbar, so painting it too would
   stack two translucent layers and darken the bar. */
windowhandle {
  background: none;
}

headerbar,
tabbar .box {
  background-color: var(--bar-bg);
  color: var(--bar-fg);
  box-shadow: none;
  border: none;
}

/* Ghostty drops .background when background-opacity is below 1. CSS cannot
   read the value, so this repeats omarchy glass's 0.65. */
window:not(.background) headerbar,
window:not(.background) tabbar .box {
  background-color: rgb(from var(--bar-bg) r g b / 0.65);
}

/* No line between the bar and the terminal. */
toolbarview > .top-bar,
toolbarview scrolledwindow > undershoot.top {
  box-shadow: none;
  background: none;
}

tabbar separator {
  background: none;
}

tabbar .box,
tabbar tab,
tabbar button {
  min-height: 0;
}

tabbar tabboxchild,
tabbar tab {
  border-radius: 0;
}

/* Tabs show the bar's glass. An inset outline marks state without shifting
   layout. Mixing in oklab keeps the steps even across themes. */
tabbar tab {
  --ink: color-mix(in oklab, var(--bar-fg) 85%, var(--bar-bg));
  --line: color-mix(in oklab, var(--bar-fg) 35%, var(--bar-bg));
  font-size: 0.85em;
  background: none;
  color: var(--ink);
  box-shadow: inset 0 0 0 1px var(--line);
  transition: color 120ms, box-shadow 120ms;
}

tabbar tab:hover {
  --ink: color-mix(in oklab, var(--bar-fg) 95%, var(--bar-bg));
  --line: color-mix(in oklab, var(--bar-fg) 60%, var(--bar-bg));
}

tabbar tab:selected {
  --ink: var(--bar-fg);
  --line: var(--bar-fg);
}

/* An unfocused window steps down so the focused one stands out. */
tabbar tab:backdrop {
  --ink: color-mix(in oklab, var(--bar-fg) 70%, var(--bar-bg));
}

tabbar tab:selected:backdrop {
  --ink: color-mix(in oklab, var(--bar-fg) 80%, var(--bar-bg));
  --line: color-mix(in oklab, var(--bar-fg) 45%, var(--bar-bg));
}

tabbar button {
  color: inherit;
  background: none;
  opacity: 0.7;
}

tabbar button:hover {
  opacity: 1;
  background-color: color-mix(in oklab, var(--bar-fg) 15%, transparent);
}

/* Progress bar from OSC 9;4. Libadwaita colors it with the system accent. */
.surface progressbar progress {
  background-color: var(--bar-fg);
}

.surface progressbar.error progress {
  background-color: var(--theme-red);
}
