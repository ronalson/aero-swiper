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
