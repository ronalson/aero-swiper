APP_NAME = AeroSwiper
LABEL = com.ronalson.aeroswiper
PLIST_FILE = $(LABEL).plist
PLIST_TEMPLATE = com.ronalson.aeroswiper.plist.in
APP_INFO_TEMPLATE = AeroSwiper.Info.plist.in
LAUNCH_AGENTS_DIR = $(HOME)/Library/LaunchAgents
APPS_DIR = $(HOME)/Applications
APP_BUNDLE = $(APPS_DIR)/$(APP_NAME).app
APP_CONTENTS_DIR = $(APP_BUNDLE)/Contents
APP_MACOS_DIR = $(APP_CONTENTS_DIR)/MacOS
APP_RESOURCES_DIR = $(APP_CONTENTS_DIR)/Resources
APP_INFO_DST = $(APP_CONTENTS_DIR)/Info.plist
LOG_DIR = $(HOME)/Library/Logs
BIN_SRC = target/release/aeroswiper
BIN_DST = $(APP_MACOS_DIR)/aeroswiper
PLIST_DST = $(LAUNCH_AGENTS_DIR)/$(PLIST_FILE)

.PHONY: test build run prompt-accessibility install restart uninstall status logs

test:
	cargo test

build:
	cargo build --release

run:
	cargo run --release

prompt-accessibility: build
	@if [ -x "$(BIN_DST)" ]; then \
		"$(BIN_DST)" --prompt-accessibility --check-accessibility || true; \
	else \
		./target/release/aeroswiper --prompt-accessibility --check-accessibility || true; \
	fi

install: build
	mkdir -p "$(APP_MACOS_DIR)" "$(APP_RESOURCES_DIR)" "$(LAUNCH_AGENTS_DIR)" "$(LOG_DIR)"
	cp "$(BIN_SRC)" "$(BIN_DST)"
	chmod 755 "$(BIN_DST)"
	cp "$(APP_INFO_TEMPLATE)" "$(APP_INFO_DST)"
	sed "s|@BINARY_PATH@|$(BIN_DST)|g; s|@OUT_LOG@|$(LOG_DIR)/aeroswiper.out|g; s|@ERR_LOG@|$(LOG_DIR)/aeroswiper.err|g" "$(PLIST_TEMPLATE)" > "$(PLIST_DST)"
	launchctl unload "$(PLIST_DST)" 2>/dev/null || true
	launchctl load "$(PLIST_DST)"
	@echo "Installed $(APP_BUNDLE) and loaded LaunchAgent $(LABEL)."
	@echo "Run 'make prompt-accessibility' once, then enable $(APP_NAME) in System Settings > Privacy & Security > Accessibility, then run 'make restart'."

restart:
	launchctl unload "$(PLIST_DST)" 2>/dev/null || true
	launchctl load "$(PLIST_DST)"
	@echo "Restarted $(LABEL)."

uninstall:
	launchctl unload "$(PLIST_DST)" 2>/dev/null || true
	rm -f "$(PLIST_DST)"
	rm -rf "$(APP_BUNDLE)"
	@echo "Uninstalled $(APP_NAME)."

status:
	launchctl list | grep "$(LABEL)" || true

logs:
	@echo "stdout: $(LOG_DIR)/aeroswiper.out"
	@echo "stderr: $(LOG_DIR)/aeroswiper.err"
	tail -n 100 "$(LOG_DIR)/aeroswiper.out" 2>/dev/null || true
	tail -n 100 "$(LOG_DIR)/aeroswiper.err" 2>/dev/null || true
