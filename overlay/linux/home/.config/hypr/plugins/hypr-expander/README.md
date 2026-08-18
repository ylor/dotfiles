# hypr-expander

hypr-expander replaces configured ASCII triggers in Hyprland applications.

Triggers and replacements accept printable ASCII characters from space through tilde.

## Build

Run `make` in this directory.

Run `make` again after each Hyprland update.

## Configuration

Add expansions after the plugin loads:

```lua
local expander = hl.plugin.hypr_expander
if not expander then
    return
end

expander.add({
    trigger = "@@",
    replacement = "replacement",
})
```

Reload the Hyprland configuration after an expansion change.

## Safety

hypr-expander runs in the compositor process. A plugin defect can terminate the Hyprland session.
