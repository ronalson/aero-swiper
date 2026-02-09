#!/bin/bash
set -euo pipefail

LABEL="com.ronalson.aeroswiper"
APP_PATH="${HOME}/Applications/AeroSwiper.app"
PLIST_PATH="${HOME}/Library/LaunchAgents/${LABEL}.plist"

launchctl bootout "gui/$(id -u)" "${PLIST_PATH}" 2>/dev/null || true
rm -f "${PLIST_PATH}"
rm -f "${HOME}/Library/Logs/aeroswiper.out" "${HOME}/Library/Logs/aeroswiper.err"

rm -rf "${APP_PATH}"

echo "AeroSwiper uninstalled."
