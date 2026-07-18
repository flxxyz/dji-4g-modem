# Changelog

## [2.0.0] - 2026-07-18

### Added
- **Pure Linux support** — removed all macOS code, Linux-only multi-distro
- **Distro detection** — auto-detects Debian/Ubuntu/RHEL/OpenWRT families
- **`preflight` command** — checks + auto-installs kernel modules and tools
- **`route` command group** — `route add|del|show` for explicit routing control
- **`connect --route` flag** — optionally add default route on connect (metric 50)
- **`connect` no longer adds default route by default** — system routing is opt-in
- **15-step `debug connectivity`** — timed end-to-end diagnostics from USB to HTTP
- **`debug system` known-good config comparison** — compares current environment against verified working configs
- **`status` three-tier state machine** — DEVICE NOT FOUND / NOT CONNECTED / connected
- **`_need_connect` guard** — all AT-dependent commands show friendly "run connect first" instead of errors
- **`_need_root` guard** — clear root requirement messages for privileged commands
- **Auto-mount debugfs** — for `debug usb` interface map on systems where it's not mounted
- **Root/preflight separation** — only `connect` triggers dependency install, read-only commands work freely
- **`TESTING.md`** — 18 test cases across 3 tiers (PVE → Debian → Ubuntu)
- **`--json` output** — `status` and `dump` support machine-readable JSON

### Fixed
- `lsusb -v` exit code triggering false "not available" messages
- Interface Map missing closing `)` in class labels like `0a(data)`
- Duplicate Interface Map entries from alternate USB configurations
- AT command timeout using `timeout` command instead of blocking `read -t`
- `dhclient` auto-adding default route conflicting with explicit `route add`
- Signal functions crashing on non-numeric RSSI values

### Verified
- PVE 7.0 (kernel 7.0.2) — full test suite
- Debian 12 Bookworm (kernel 6.1.0) — full test suite
- Ubuntu 22.04 Jammy (kernel 5.15.0-generic) — full test suite

## [1.0.0] - 2026-07-17

### Added
- Initial release — PVE/Proxmox-focused
- `connect` / `disconnect` / `status` / `info` / `signal` / `at` commands
- `debug` subsystem: usb, driver, modem, network, connectivity, system
- `dump` — full diagnostic output
- `monitor` — USB hotplug watcher
- `env` — platform environment info
- macOS diagnostic mode (removed in 2.0.0)
- Basic distro detection
- CDC ECM + option driver binding
- PPP fallback (abandoned in favor of ECM)
