CXX ?= c++
PKG_CONFIG ?= pkg-config

TARGET := hypr-expander-0.0.1.so
TEMP_TARGET := hypr-expander-0.0.1.tmp.so
SOURCE := hypr-expander.cpp
PACKAGES := hyprland lua

CPPFLAGS += $(shell $(PKG_CONFIG) --cflags $(PACKAGES))
CXXFLAGS ?= -O2
PLUGIN_FLAGS := -std=c++23 -fPIC -fvisibility=hidden -Wall -Wextra -Wpedantic
PLUGIN_LDFLAGS := -shared -Wl,--as-needed
LDLIBS += $(shell $(PKG_CONFIG) --libs $(PACKAGES))

.PHONY: all clean force

all: $(TARGET)

# Hyprland plugins must match the installed Hyprland ABI.
$(TARGET): $(SOURCE) Makefile force
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(PLUGIN_FLAGS) $(LDFLAGS) $(PLUGIN_LDFLAGS) -o $(TEMP_TARGET) $(SOURCE) $(LDLIBS)
	mv $(TEMP_TARGET) $(TARGET)

force:

clean:
	rm -f $(TARGET) $(TEMP_TARGET)
