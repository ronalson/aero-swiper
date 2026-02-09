#!/bin/bash
set -euo pipefail

export COPYFILE_DISABLE=1

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="dev"

if [ "${#}" -ge 1 ]; then
  VERSION="$1"
fi

BIN_SRC="${ROOT_DIR}/target/release/aeroswiper"
if [ ! -x "${BIN_SRC}" ]; then
  echo "Missing release binary: ${BIN_SRC}"
  echo "Run: cargo build --release"
  exit 1
fi

if ! command -v pkgbuild >/dev/null 2>&1; then
  echo "pkgbuild is required (macOS only)."
  exit 1
fi

SCRIPTS_DIR="${ROOT_DIR}/dist/pkgscripts"
APP_BUILD_DIR="${ROOT_DIR}/dist/appbuild"
APP_ROOT="${APP_BUILD_DIR}/AeroSwiper.app/Contents"
APP_ARCHIVE="${SCRIPTS_DIR}/AeroSwiper.app.tar.gz"
OUT_PKG="${ROOT_DIR}/dist/aeroswiper-macos-arm64-${VERSION}.pkg"

PKG_VERSION="${VERSION#v}"
if ! [[ "${PKG_VERSION}" =~ ^[0-9]+(\.[0-9]+){0,2}$ ]]; then
  PKG_VERSION="0.0.0"
fi

rm -rf "${APP_BUILD_DIR}" "${SCRIPTS_DIR}"
mkdir -p "${APP_ROOT}/MacOS" "${APP_ROOT}/Resources"
mkdir -p "${SCRIPTS_DIR}"

cp "${BIN_SRC}" "${APP_ROOT}/MacOS/aeroswiper"
cp "${ROOT_DIR}/AeroSwiper.Info.plist.in" "${APP_ROOT}/Info.plist"
cp "${ROOT_DIR}/scripts/release/pkg/uninstall.sh" "${APP_ROOT}/Resources/uninstall.sh"
cp "${ROOT_DIR}/scripts/release/pkg/postinstall" "${SCRIPTS_DIR}/postinstall"

chmod 755 "${APP_ROOT}/MacOS/aeroswiper" "${APP_ROOT}/Resources/uninstall.sh" "${SCRIPTS_DIR}/postinstall"
tar -C "${APP_BUILD_DIR}" -czf "${APP_ARCHIVE}" "AeroSwiper.app"

rm -f "${OUT_PKG}"
pkgbuild \
  --nopayload \
  --scripts "${SCRIPTS_DIR}" \
  --identifier "com.ronalson.aeroswiper" \
  --version "${PKG_VERSION}" \
  --install-location "/" \
  "${OUT_PKG}"

echo "Created ${OUT_PKG}"
