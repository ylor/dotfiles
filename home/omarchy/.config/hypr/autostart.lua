-- Extra autostart processes.
-- o.launch_on_start("my-service")

o.exec_on_start("1password --silent")

o.exec_on_start("[workspace 1 silent; no_initial_focus; suppress_event activate activatefocus] helium-browser")
o.exec_on_start("[workspace 2 silent; no_initial_focus; suppress_event activate activatefocus] ghostty")

-- Keep GNOME applications' font rendering consistent across sessions.
o.exec_on_start("gsettings set org.gnome.desktop.interface font-name 'Berkeley Mono Variable 11'")
o.exec_on_start("gsettings set org.gnome.desktop.interface document-font-name 'Berkeley Mono Variable 12'")
o.exec_on_start("gsettings set org.gnome.desktop.interface monospace-font-name 'Berkeley Mono Variable 11'")
o.exec_on_start("gsettings set org.gnome.desktop.wm.preferences button-layout ''")
