# AGENTS.md

AeroSwiper is a minimal macOS background app (Rust core + Objective-C bridge) that maps fixed 3-finger trackpad swipes to AeroSpace workspace `prev/next` over the local AeroSpace socket.

## Non-standard commands
- Run tests with `make test` (wrapper over Cargo tests).
- Build release binary with `make build`.
- Run interactively with `make run`.
- Install background service with `make install` (builds, installs binary, writes/loads LaunchAgent).
- Restart LaunchAgent with `make restart`.
- Check service registration with `make status`.
- Read service logs with `make logs`.
- Remove service with `make uninstall`.

## Critical conventions
- Keep gesture behavior minimal: fixed 3-finger detection only; no config file, haptics, or skip-empty workflow unless explicitly introduced.
- Transport contract: workspace switching must go through AeroSpace socket and retain one reconnect retry on command failure.
- Keep macOS bridge thin: AppKit/ApplicationServices event-tap/touch capture stays in `bridge/swipe_bridge.m`; gesture/switching logic lives in Rust.
- Maintain binary/service identity names:
  - Binary: `aeroswiper`
  - App name: `AeroSwiper`
  - LaunchAgent label: `com.ronalson.aeroswiper`

## Workflow constraints
- Before changing runtime behavior, run `make test` and keep all tests green.
- For install/runtime changes, verify plist and paths remain aligned with `Makefile` variables (`LABEL`, `PLIST_TEMPLATE`, `BIN_DST`).
- Avoid introducing new long-running loops in Rust for retries; launch lifecycle is managed by LaunchAgent.
- Treat Accessibility prompt flow as sensitive: changes to startup/permission logic must avoid repeated prompt loops.
