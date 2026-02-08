#!/bin/bash
set -euo pipefail

APP_NAME="AeroSwiper"
LABEL="com.ronalson.aeroswiper"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

APPS_DIR="${HOME}/Applications"
APP_BUNDLE="${APPS_DIR}/${APP_NAME}.app"
LAUNCH_AGENTS_DIR="${HOME}/Library/LaunchAgents"
PLIST_DST="${LAUNCH_AGENTS_DIR}/${LABEL}.plist"
LOG_DIR="${HOME}/Library/Logs"
BIN_PATH="${APP_BUNDLE}/Contents/MacOS/aeroswiper"
PLIST_TEMPLATE="${SCRIPT_DIR}/${LABEL}.plist.in"

if [ ! -d "${SCRIPT_DIR}/${APP_NAME}.app" ]; then
  echo "Missing ${APP_NAME}.app next to install.sh"
  exit 1
fi

if [ ! -f "${PLIST_TEMPLATE}" ]; then
  echo "Missing plist template: ${PLIST_TEMPLATE}"
  exit 1
fi

mkdir -p "${APPS_DIR}" "${LAUNCH_AGENTS_DIR}" "${LOG_DIR}"

rm -rf "${APP_BUNDLE}"
cp -R "${SCRIPT_DIR}/${APP_NAME}.app" "${APP_BUNDLE}"
chmod 755 "${BIN_PATH}"

sed \
  "s|@BINARY_PATH@|${BIN_PATH}|g; s|@OUT_LOG@|${LOG_DIR}/aeroswiper.out|g; s|@ERR_LOG@|${LOG_DIR}/aeroswiper.err|g" \
  "${PLIST_TEMPLATE}" > "${PLIST_DST}"

launchctl unload "${PLIST_DST}" 2>/dev/null || true
launchctl load "${PLIST_DST}"

echo "Installed ${APP_BUNDLE} and loaded LaunchAgent ${LABEL}."
echo "Next steps:"
echo "1) Run: ${BIN_PATH} --prompt-accessibility --check-accessibility || true"
echo "2) Enable AeroSwiper in System Settings > Privacy & Security > Accessibility"
echo "3) Run: launchctl unload \"${PLIST_DST}\" 2>/dev/null || true; launchctl load \"${PLIST_DST}\""
