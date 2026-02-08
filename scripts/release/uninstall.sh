#!/bin/bash
set -euo pipefail

APP_NAME="AeroSwiper"
LABEL="com.ronalson.aeroswiper"
APPS_DIR="${HOME}/Applications"
APP_BUNDLE="${APPS_DIR}/${APP_NAME}.app"
PLIST_DST="${HOME}/Library/LaunchAgents/${LABEL}.plist"

launchctl unload "${PLIST_DST}" 2>/dev/null || true
rm -f "${PLIST_DST}"
rm -rf "${APP_BUNDLE}"

echo "Uninstalled ${APP_NAME}."
