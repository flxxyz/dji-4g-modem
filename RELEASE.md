# Release Checklist

## Before Tagging

### 1. Changelog Review

```bash
# Compare with previous tag
git diff $(git describe --tags --abbrev=0)..HEAD --stat
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# Update CHANGELOG.md with all changes
#   - Added / Fixed / Changed / Verified sections
```

### 2. Syntax Check

```bash
bash -n dji4g && echo PASS
```

### 3. Smoke Test Pipeline

Test in **fixed order**: Ubuntu → Debian → CentOS → OpenWRT → Raspberry Pi OS

For each system, the cycle is:
1. Inject USB passthrough (`qm set <vmid> --usb0 host=2ca3:4006`)
2. Start VM, wait for SSH
3. Deploy dji4g and run tests
4. Shutdown VM
5. Remove USB passthrough (`qm set <vmid> --delete usb0`)
6. Move to next system

```bash
# ============================================
# PVE_HOST="pve"
# DEVICE="2ca3:4006"
# SCRIPT="./dji4g"
# ============================================

# --- Ubuntu ---
ssh $PVE_HOST "qm set 120 --usb0 host=$DEVICE && qm start 120"
sleep 25
scp $SCRIPT ubuntu@<ubuntu-ip>:~/
ssh ubuntu@<ubuntu-ip> "sudo cp ~/dji4g /usr/local/bin/ && sudo dji4g connect --route && dji4g status && sudo dji4g disconnect"
ssh $PVE_HOST "qm shutdown 120 && sleep 5 && qm set 120 --delete usb0"

# --- Debian ---
ssh $PVE_HOST "qm set 121 --usb0 host=$DEVICE && qm start 121"
sleep 25
scp $SCRIPT debian@<debian-ip>:~/
ssh debian@<debian-ip> "sudo cp ~/dji4g /usr/local/bin/ && sudo dji4g connect --route && dji4g status && sudo dji4g disconnect"
ssh $PVE_HOST "qm shutdown 121 && sleep 5 && qm set 121 --delete usb0"

# --- CentOS ---
# (VM ID and IP as configured)
ssh $PVE_HOST "qm set <centos-vmid> --usb0 host=$DEVICE && qm start <centos-vmid>"
# ... same pattern

# --- OpenWRT ---
# (VM ID and IP as configured; note: uses udhcpc not dhclient, opkg not apt)
ssh $PVE_HOST "qm set <owrt-vmid> --usb0 host=$DEVICE && qm start <owrt-vmid>"
# ... same pattern

# --- Raspberry Pi OS ---
# Physical device; manually: scp dji4g → connect → test → disconnect
```

### 4. PVE Host Test (Optional)

```bash
scp dji4g $PVE_HOST:/usr/local/bin/
ssh $PVE_HOST "dji4g env && sudo dji4g connect --route && dji4g status && sudo dji4g disconnect"
```

### 5. Bump & Tag

```bash
# 5a. Bump version in dji4g
sed -i 's/SCRIPT_VERSION="X.Y.Z"/SCRIPT_VERSION="X.Y.Z+1"/' dji4g

# 5b. Commit
git add -A
git commit -m "Release vX.Y.Z

$(sed -n '/## \[X.Y.Z\]/,/## \[/p' CHANGELOG.md | tail -n +2 | head -n -1)"

# 5c. Tag
git tag -a vX.Y.Z -m "vX.Y.Z"
```

## Version Bump Rules

| Change | Bump |
|--------|------|
| New command or debug group | MINOR |
| Bug fix, output format change | PATCH |
| Platform support added/removed | MINOR |
| Breaking behavior change | MAJOR |

## Test Matrix

| Order | System | Usual VM ID | Notes |
|-------|--------|-------------|-------|
| 1 | Ubuntu 22.04+ | 120 | `apt`, `dhclient`, may need `linux-modules-extra` |
| 2 | Debian 12+ | 121 | `apt`, `dhclient`, cdc_ether auto-binds |
| 3 | CentOS/RHEL 8+ | TBD | `yum`/`dnf`, `dhclient`, SELinux |
| 4 | OpenWRT 21+ | TBD | `opkg`, `udhcpc`, busybox shell |
| 5 | Raspberry Pi OS | N/A | Physical device, `apt`, `dhclient` |
| * | PVE 7.x/8.x | N/A | Optional, host-level test |

## Known Platform Issues

| System | Issue | Workaround |
|--------|-------|------------|
| Ubuntu cloud image | Missing `linux-modules-extra` for `option` driver | `dji4g preflight` auto-installs |
| Ubuntu `-kvm` kernel | No USB host drivers at all | Use generic kernel |
| OpenWRT | No `timeout` command | Falls back to `sleep + kill` |
| CentOS/RHEL | SELinux may block `/sys` writes | `setenforce 0` temporarily |
| CentOS/RHEL | Missing `usbutils` package | `dji4g preflight` auto-installs |
