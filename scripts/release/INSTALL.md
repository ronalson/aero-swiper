# AeroSwiper Release Install

## 1) Pick the right archive
- Apple Silicon (M1/M2/M3/M4): `aeroswiper-macos-arm64-<version>.tar.gz`

Tip: run `uname -m`
- `arm64` => Apple Silicon
If output is not `arm64`, this release package is not supported on your device.

## 2) Extract and install
```bash
tar -xzf aeroswiper-macos-<arch>-<version>.tar.gz
cd aeroswiper-macos-arm64
./install.sh
```

## 3) Grant Accessibility
When prompted, enable `AeroSwiper` in:
System Settings -> Privacy & Security -> Accessibility

## 4) Uninstall (optional)
```bash
cd aeroswiper-macos-arm64
./uninstall.sh
```
