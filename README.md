# AeroSwiper

A minimal macOS app for AeroSpace workspace switching:
- fixed 3-finger swipe gesture
- swipe left/right -> `workspace prev/next`
- socket reconnect retry on command failure
- runs as a LaunchAgent (no open terminal required)

## Install
1. Download `aeroswiper-macos-arm64-<version>.pkg` from GitHub Releases.
2. Double-click the `.pkg` and complete installation.
3. Trigger the Accessibility prompt:
```bash
~/Applications/AeroSwiper.app/Contents/MacOS/aeroswiper --prompt-accessibility --check-accessibility || true
```
4. Enable `AeroSwiper` in System Settings -> Privacy & Security -> Accessibility.
5. If needed, restart the app (just run it).

If macOS blocks the app:
```bash
xattr -dr com.apple.quarantine ~/Applications/AeroSwiper.app
```

## Uninstall
```bash
~/Applications/AeroSwiper.app/Contents/Resources/uninstall.sh
```

Remove privacy permissions:
```bash
tccutil reset Accessibility com.ronalson.aeroswiper || tccutil reset Accessibility
```

Verify uninstall:
```bash
ls -la ~/Applications/AeroSwiper.app
ls -la ~/Library/LaunchAgents/com.ronalson.aeroswiper.plist
launchctl print gui/$(id -u)/com.ronalson.aeroswiper
```

## Development Guide
### Requirements
- macOS (Apple Silicon / arm64)
- Rust/Cargo
- AeroSpace running

### Local build and installation
```bash
cd aero-swiper
make test
make build
make install
make prompt-accessibility
make restart
```

Useful local commands:
```bash
make status
make logs
make uninstall
```

## Publishing Guide
### Build
Build local `.pkg` artifact:
```bash
cargo build --release
bash scripts/package_release.sh v0.1.2
```

Output:
`dist/aeroswiper-macos-arm64-v0.1.2.pkg`

### GitHub Action
1. Push code to `main`.
2. Create and push a semver tag:
```bash
git tag v0.1.2
git push origin v0.1.2
```
3. GitHub Actions workflow `.github/workflows/release.yml` builds and publishes the `.pkg` to GitHub Releases.
