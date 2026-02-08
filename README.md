# AeroSwiper

A minimal macOS app for AeroSpace workspace switching:
- fixed 3-finger swipe gesture
- swipe left/right -> `workspace prev/next`
- socket reconnect retry on command failure
- runs as a LaunchAgent (no open terminal required)

## Requirements
- macOS
- Rust/Cargo
- AeroSpace running
- Accessibility permission granted to `AeroSwiper`

## Test and build
```bash
cd aero-swiper
make test
make build
```

## Install (background service)
```bash
cd aero-swiper
make install
make prompt-accessibility
make restart
```

This will:
- build release binary
- install app bundle at `~/Applications/AeroSwiper.app`
- install LaunchAgent plist at `~/Library/LaunchAgents/com.ronalson.aeroswiper.plist`
- load the LaunchAgent
- open the Accessibility permission prompt (`make prompt-accessibility`)

## Control
```bash
make prompt-accessibility
make restart
make status
make logs
make uninstall
```

## First-run note
If gestures do not work immediately:
1. Run `make prompt-accessibility` once to show the macOS permission dialog.
2. Open System Settings -> Privacy & Security -> Accessibility.
3. Enable access for `AeroSwiper`.
4. Run `make restart`.

The LaunchAgent no longer continuously respawns while permission is missing, so you should not see repeated prompt loops.
The app is now installed as `~/Applications/AeroSwiper.app`, so it is easier to locate in the Accessibility picker.

## Optional socket override
Set `AEROSPACE_SOCKET_PATH` in the LaunchAgent plist if you use a non-default path.

## Security note
`AeroSwiper` requires macOS Accessibility permission to observe gesture events. Grant access only to builds from source you trust and review.

## Binary distribution (GitHub Releases)
This repo includes packaging + GitHub Actions to publish unsigned macOS release archives for Apple Silicon (arm64) only.

Each release artifact contains:
- `AeroSwiper.app`
- `install.sh`
- `uninstall.sh`
- `INSTALL.md`

### Maintainer setup (one-time)
1. Push this repository (including `.github/workflows/release.yml`).
2. In GitHub repo settings, ensure Actions are enabled with read/write workflow permissions for releases.
3. No secrets are required for this unsigned workflow.

### Publish a release
1. Create and push a semver tag:
```bash
git tag v0.1.0
git push origin v0.1.0
```
2. GitHub Actions will build on `macos-14` (`arm64`), package artifacts, and publish a GitHub Release automatically.

### Optional: create release with GitHub CLI
You can also trigger a release manually after local packaging:
```bash
cargo build --release
bash scripts/package_release.sh arm64 v0.1.0
gh release create v0.1.0 dist/aeroswiper-macos-arm64-v0.1.0.tar.gz --generate-notes
```

### End-user install from release archive
1. Download `aeroswiper-macos-arm64-<version>.tar.gz` from GitHub Releases.
2. Check architecture if needed: `uname -m` (must be `arm64`).
3. Extract it and run:
```bash
tar -xzf aeroswiper-macos-arm64-<version>.tar.gz
cd aeroswiper-macos-arm64
./install.sh
```
4. Grant Accessibility permission when prompted.
5. See bundled `INSTALL.md` for quick reference.
