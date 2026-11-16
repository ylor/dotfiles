# Rebuilds when the source changes or Hyprland is reinstalled or upgraded.
# Packaged headers keep the package's build time as their mtime, which can be older than
# the last plugin build, so depend on pacman's install record instead.
# Builds to a temp file and swaps it in, so a running Hyprland never sees a half-written file.
HYPRLAND_INSTALL := $(wildcard /var/lib/pacman/local/hyprland-[0-9]*/desc)

hypr-expandr.so: hypr-expandr.cpp $(HYPRLAND_INSTALL)
	g++ -O2 -shared -fPIC -std=c++2b --no-gnu-unique hypr-expandr.cpp -o $@.tmp \
		`pkg-config --cflags pixman-1 libdrm hyprland libinput libudev wayland-server xkbcommon lua`
	mv $@.tmp $@
