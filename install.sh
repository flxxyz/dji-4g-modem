#!/usr/bin/env bash
#===============================================================================
# dji4g installer — https://dji-4g-modem.sao.sh
# Run:  curl -fsSL https://dji-4g-modem.sao.sh/install.sh | bash
#===============================================================================
set -euo pipefail

DOWNLOAD_BASE="https://dji-4g-modem.sao.sh"
INSTALL_PATH="/usr/local/bin/dji4g"
MIN_KERNEL_MAJ=5
MIN_KERNEL_MIN=4

# ----[ Colors ]----
R='\033[31m' G='\033[32m' Y='\033[33m' C='\033[36m' B='\033[1m' N='\033[0m'
info()  { echo -e "${C}==>${N} $*"; }
ok()   { echo -e "  ${G}[OK]${N} $*"; }
warn()  { echo -e "  ${Y}[WARN]${N} $*"; }
die()  { echo -e "${R}${B}ERROR:${N} $*" >&2; exit 1; }

# ----[ Step 1: Root ]----
if [ "$(id -u)" -ne 0 ]; then
    info "Need root to install. Elevating..."
    exec sudo bash "$0" "$@"
fi

echo ""
echo -e "${B}${C}dji4g installer${N}"
echo "=============================="
echo ""

# ----[ Step 2: Detect distro ]----
info "Step 1/5: Detecting system..."

DISTRO_ID="" DISTRO_VER=""
if [ -f /etc/os-release ]; then
    DISTRO_ID=$(grep '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    DISTRO_VER=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
elif [ -f /etc/openwrt_release ]; then
    DISTRO_ID="openwrt"
    DISTRO_VER=$(grep 'DISTRIB_RELEASE' /etc/openwrt_release | cut -d"'" -f2)
elif [ -f /etc/rpi-issue ]; then
    DISTRO_ID="raspbian"
fi

ARCH=$(uname -m)
KERNEL_VER=$(uname -r)

# Map to package manager
case "$DISTRO_ID" in
    ubuntu|debian|linuxmint|pop|raspbian|kali)
        PKG_MGR="apt-get"
        PKG_INSTALL="apt-get install -y -qq"
        PKG_UPDATE="apt-get update -qq"
        BASH_PKG="bash"
        EXTRA_PKGS="usbutils isc-dhcp-client iproute2 curl"
        KERNEL_PKG="linux-image-generic"
        ;;
    centos|rhel|fedora|rocky|almalinux|amzn)
        PKG_MGR="yum"
        PKG_INSTALL="yum install -y -q"
        PKG_UPDATE="yum check-update -q || true"
        BASH_PKG="bash"
        EXTRA_PKGS="usbutils dhclient iproute curl"
        KERNEL_PKG="kernel"
        ;;
    openwrt)
        PKG_MGR="opkg"
        PKG_INSTALL="opkg install"
        PKG_UPDATE="opkg update -q"
        BASH_PKG="bash"
        EXTRA_PKGS="usbutils udhcpc ip curl"
        KERNEL_PKG=""
        ;;
    *)
        ISSUE_TITLE="unsupported%20distro%3A%20${DISTRO_ID:-unknown}"
        ISSUE_BODY="Distro%3A%20${DISTRO_ID:-unknown}%20${DISTRO_VER:-}%0AArch%3A%20${ARCH}%0AKernel%3A%20${KERNEL_VER}"
        die "Unsupported distribution: ${DISTRO_ID:-unknown} (${DISTRO_VER:-unknown}, ${ARCH})

  This installer supports Ubuntu, Debian, CentOS, RHEL, OpenWRT, and Raspberry Pi OS.

  If you believe this is an error, please open an issue:
  https://github.com/flxxyz/dji-4g-modem/issues/new?title=${ISSUE_TITLE}&body=${ISSUE_BODY}"
        ;;
esac

ok "Detected ${DISTRO_ID} ${DISTRO_VER} (${ARCH}, kernel ${KERNEL_VER})"

# ----[ Step 3: Install dependencies ]----
info "Step 2/5: Installing system dependencies..."

$PKG_UPDATE 2>/dev/null || true

# Ensure bash is installed (essential for the script)
if ! command -v bash &>/dev/null; then
    info "  Installing bash..."
    $PKG_INSTALL $BASH_PKG
fi

# Install required tools (already-installed packages are skipped by pkg mgr)
$PKG_INSTALL $EXTRA_PKGS 2>&1 | tail -3

ok "System dependencies ready"

# ----[ Step 4: Kernel check ]----
info "Step 3/5: Checking kernel version..."

K_MAJ=$(echo "$KERNEL_VER" | cut -d. -f1)
K_MIN=$(echo "$KERNEL_VER" | cut -d. -f2 | grep -o '^[0-9]*')

kernel_too_old=false
if [ "$K_MAJ" -lt "$MIN_KERNEL_MAJ" ] || { [ "$K_MAJ" -eq "$MIN_KERNEL_MAJ" ] && [ "$K_MIN" -lt "$MIN_KERNEL_MIN" ]; }; then
    kernel_too_old=true
fi

if $kernel_too_old; then
    warn "Your kernel (${KERNEL_VER}) is older than ${MIN_KERNEL_MAJ}.${MIN_KERNEL_MIN}."
    echo ""
    echo "  The CDC ECM driver requires kernel >= ${MIN_KERNEL_MAJ}.${MIN_KERNEL_MIN} for reliable operation."
    echo "  A newer kernel also ensures better USB device compatibility."
    echo ""

    if [ -n "$KERNEL_PKG" ] && [ "$PKG_MGR" != "opkg" ]; then
        echo -n "  Install ${KERNEL_PKG} now? [Y/n] "
        read -r answer
        case "${answer:-y}" in
            [Yy]*)
                info "Installing ${KERNEL_PKG}..."
                $PKG_INSTALL $KERNEL_PKG 2>&1 | tail -3
                ok "Kernel package installed. Reboot to use new kernel, then run:"
                echo "      sudo dji4g connect --route"
                echo ""
                warn "You need to reboot before the new kernel takes effect."
                ;;
            *)
                warn "Skipping kernel upgrade. The module may not work reliably."
                ;;
        esac
    else
        warn "Cannot auto-upgrade kernel on ${DISTRO_ID}. Please upgrade manually."
    fi
else
    ok "Kernel ${KERNEL_VER} meets minimum requirements (>= ${MIN_KERNEL_MAJ}.${MIN_KERNEL_MIN})"
fi

# ----[ Step 5: Download dji4g ]----
info "Step 4/5: Downloading dji4g..."

tmpfile=$(mktemp /tmp/dji4g.XXXXXX)
if command -v curl &>/dev/null; then
    curl -fsSL "${DOWNLOAD_BASE}/dji4g" -o "$tmpfile"
elif command -v wget &>/dev/null; then
    wget -q "${DOWNLOAD_BASE}/dji4g" -O "$tmpfile"
else
    die "Neither curl nor wget found. Install one and retry."
fi

chmod +x "$tmpfile"
mv "$tmpfile" "$INSTALL_PATH"

ok "Installed to ${INSTALL_PATH}"

# ----[ Step 6: Verify ]----
info "Step 5/5: Verifying installation..."

if "$INSTALL_PATH" version >/dev/null 2>&1; then
    echo ""
    "$INSTALL_PATH" env
else
    die "Installation verification failed"
fi

# ----[ Done ]----
echo ""
echo -e "  ${G}${B}Installation complete!${N}"
echo ""
echo "  To get online:"
echo "    sudo dji4g connect --route"
echo ""
echo "  To check status:"
echo "    dji4g status"
echo ""
echo "  If the 4G module is not plugged in right now:"
echo "    ✈️  Plug it in, then run the commands above."

echo ""
echo -e "  ${C}Remember: the USB cable must support DATA transfer.${N}"
echo -e "  ${C}A charge-only cable will NOT work.${N}"
echo ""
