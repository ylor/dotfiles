# Rebuilds when the source or the installed Hyprland headers change.
# Builds to a temp file and swaps it in, so a running Hyprland never sees a half-written file.
HYPRLAND_VERSION := /usr/include/hyprland/src/version.h

hypr-expandr.so: hypr-expandr.cpp $(HYPRLAND_VERSION)
	g++ -O2 -shared -fPIC -std=c++2b --no-gnu-unique hypr-expandr.cpp -o $@.tmp \
		`pkg-config --cflags pixman-1 libdrm hyprland libinput libudev wayland-server xkbcommon lua`
	mv $@.tmp $@
