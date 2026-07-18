# Roadmap

## Done (v2.0.0)

- [x] `connect` / `disconnect` — bring 4G online/offline
- [x] `status` — three-tier state machine (not found → not connected → connected)
- [x] `info` — modem identity, registration, signal
- [x] `signal` — real-time RSSI with ASCII bar
- [x] `at` — raw AT command interface
- [x] `route` — explicit default route management (add/del/show)
- [x] `sms send` — send SMS via AT+CMGS (text mode)
- [x] `cell` — serving cell identity, band, bandwidth, signal metrics
- [x] `debug` — 6 layers (usb/driver/modem/network/connectivity/system)
- [x] `dump` — full diagnostic output
- [x] `preflight` — auto-install missing dependencies
- [x] `monitor` — USB hotplug watcher
- [x] `env` — platform environment info
- [x] Multi-distro: Debian/Ubuntu/RHEL/OpenWRT families
- [x] Git repo with versioned releases

## Backlog

### Short-term
- [ ] **SMS read** — `sms list` / `sms read <n>` — read inbox messages
- [ ] **USSD** — `ussd *100#` — balance/plan queries
- [ ] **GPS** — `gps` — hardware confirmed (QGPS=1), but needs outdoor signal

### Medium-term
- [ ] **Systemd service** — auto-connect on boot
- [ ] **Keepalive** — watch mode with auto-reconnect
- [ ] **Data stats** — traffic counter via `AT+QGDCNT?`
- [ ] **Scan** — operator scan `AT+COPS=?`

### Later
- [ ] **SMS remote control** — execute commands via SMS
- [ ] **Multi-WAN / policy routing** — per-destination routing
- [ ] **Metrics export** — Prometheus endpoint
- [ ] **Web UI** — status dashboard

## Won't Do

- RouterOS support (proprietary userland, needs separate implementation)
- macOS network routing (Apple Silicon + Sequoia blocks third-party kexts)
