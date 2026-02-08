#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARCH="arm64"
VERSION="dev"

if [ "${#}" -ge 1 ]; then
  if [ "$1" = "arm64" ]; then
    ARCH="$1"
    if [ "${#}" -ge 2 ]; then
      VERSION="$2"
    fi
  else
    VERSION="$1"
  fi
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
cp "${ROOT_DIR}/scripts/release/install.sh" "${PKG_ROOT}/install.sh"
cp "${ROOT_DIR}/scripts/release/uninstall.sh" "${PKG_ROOT}/uninstall.sh"
cp "${ROOT_DIR}/scripts/release/INSTALL.md" "${PKG_ROOT}/INSTALL.md"

chmod 755 "${APP_ROOT}/MacOS/aeroswiper" "${PKG_ROOT}/install.sh" "${PKG_ROOT}/uninstall.sh"

rm -f "${OUT_ARCHIVE}"
tar -C "${ROOT_DIR}/dist" -czf "${OUT_ARCHIVE}" "${PKG_NAME}"
echo "Created ${OUT_ARCHIVE}"
