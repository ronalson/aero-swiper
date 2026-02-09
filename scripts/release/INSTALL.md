# AeroSwiper Package Install (arm64)

## Install
1. Download `aeroswiper-macos-arm64-<version>.pkg` from GitHub Releases.
2. Double-click the `.pkg` and complete the installer.
3. Trigger the Accessibility prompt:
```bash
~/Applications/AeroSwiper.app/Contents/MacOS/aeroswiper --prompt-accessibility --check-accessibility || true
```
4. Open System Settings -> Privacy & Security -> Accessibility and enable `AeroSwiper`.

## If macOS blocks the app after install
In Terminal:
```bash
xattr -dr com.apple.quarantine ~/Applications/AeroSwiper.app
```
Then restart your session or run:
```bash
launchctl kickstart -k gui/$(id -u)/com.ronalson.aeroswiper
```

## Uninstall
```bash
~/Applications/AeroSwiper.app/Contents/Resources/uninstall.sh
```
