#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="${1:-}"
VERSION="${2:-dev}"

if [ -z "${ARCH}" ]; then
  echo "Usage: scripts/package_release.sh <arm64|x86_64> [version]"
  exit 1
fi

BIN_SRC="${ROOT_DIR}/target/release/aeroswiper"
if [ ! -x "${BIN_SRC}" ]; then
  echo "Missing release binary: ${BIN_SRC}"
  echo "Run: cargo build --release"
  exit 1
fi

PKG_NAME="aeroswiper-macos-${ARCH}"
PKG_ROOT="${ROOT_DIR}/dist/${PKG_NAME}"
APP_ROOT="${PKG_ROOT}/AeroSwiper.app/Contents"
OUT_ARCHIVE="${ROOT_DIR}/dist/${PKG_NAME}-${VERSION}.tar.gz"

rm -rf "${PKG_ROOT}"
mkdir -p "${APP_ROOT}/MacOS" "${APP_ROOT}/Resources"

cp "${BIN_SRC}" "${APP_ROOT}/MacOS/aeroswiper"
cp "${ROOT_DIR}/AeroSwiper.Info.plist.in" "${APP_ROOT}/Info.plist"
cp "${ROOT_DIR}/com.ronalson.aeroswiper.plist.in" "${PKG_ROOT}/com.ronalson.aeroswiper.plist.in"
cp "${ROOT_DIR}/scripts/release/install.sh" "${PKG_ROOT}/install.sh"
cp "${ROOT_DIR}/scripts/release/uninstall.sh" "${PKG_ROOT}/uninstall.sh"
cp "${ROOT_DIR}/README.md" "${PKG_ROOT}/README.md"

chmod 755 "${APP_ROOT}/MacOS/aeroswiper" "${PKG_ROOT}/install.sh" "${PKG_ROOT}/uninstall.sh"

rm -f "${OUT_ARCHIVE}"
tar -C "${ROOT_DIR}/dist" -czf "${OUT_ARCHIVE}" "${PKG_NAME}"
echo "Created ${OUT_ARCHIVE}"
