CC ?= clang
MIN_VER ?= 15.0
SUPPORT_DIR ?= $(HOME)/Library/Application Support/notproton
PLUGIN_DIR  ?= $(SUPPORT_DIR)/plugins

DYLIB_NAME := libfpslimit.dylib
OUT_DIR    := bin
TARGET     := $(OUT_DIR)/$(DYLIB_NAME)
CONF_NAME  := fpslimit.conf

FLAGS := -mmacosx-version-min=$(MIN_VER) -Werror=unguarded-availability-new \
         -dynamiclib -O2 -Wall -Wextra \
         -framework Metal -framework QuartzCore \
         -framework CoreFoundation -framework Foundation \
         -install_name @rpath/$(DYLIB_NAME)

all: $(TARGET)

$(TARGET): fpslimit.m
	@mkdir -p $(OUT_DIR)
	$(CC) -arch arm64 $(FLAGS) -o $(OUT_DIR)/libfpslimit.arm64.dylib $<
	$(CC) -arch x86_64 $(FLAGS) -o $(OUT_DIR)/libfpslimit.x86_64.dylib $<
	lipo -create $(OUT_DIR)/libfpslimit.arm64.dylib $(OUT_DIR)/libfpslimit.x86_64.dylib -output $@
	codesign -fs - $@
	@echo "==> Successfully built universal $(TARGET)"
	@lipo -info $@

install: $(TARGET)
	@mkdir -p "$(SUPPORT_DIR)" "$(PLUGIN_DIR)"
	cp -f $(TARGET) "$(SUPPORT_DIR)/$(DYLIB_NAME).new"
	mv -f "$(SUPPORT_DIR)/$(DYLIB_NAME).new" "$(SUPPORT_DIR)/$(DYLIB_NAME)"
	cp -f $(CONF_NAME) "$(PLUGIN_DIR)/$(CONF_NAME).new"
	mv -f "$(PLUGIN_DIR)/$(CONF_NAME).new" "$(PLUGIN_DIR)/$(CONF_NAME)"
	@echo "==> Installed $(DYLIB_NAME) -> $(SUPPORT_DIR)/"
	@echo "==> Installed $(CONF_NAME) -> $(PLUGIN_DIR)/"
	@echo "Restart Steam to see the FPS Limiter slider in your game's Compatibility tab!"

uninstall:
	rm -f "$(SUPPORT_DIR)/$(DYLIB_NAME)"
	rm -f "$(PLUGIN_DIR)/$(CONF_NAME)"
	@echo "==> Uninstalled fpslimit plugin."

clean:
	rm -rf $(OUT_DIR)

.PHONY: all install uninstall clean
