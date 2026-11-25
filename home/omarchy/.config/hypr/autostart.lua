o.launch_on_start("hyprsunset")

o.exec_on_start("1password --silent")

o.exec_on_start("[workspace 1 silent; no_initial_focus] claude-desktop")
o.exec_on_start("[workspace 1 silent; no_initial_focus; scrolling_width 1.0] omarchy-launch-browser")
o.exec_on_start("[workspace 2 silent; no_initial_focus; suppress_event activate activatefocus] ghostty")

o.exec_on_start("gsettings set org.gnome.desktop.wm.preferences button-layout ''")
