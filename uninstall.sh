#!/usr/bin/env bash
# ==============================================================================
# Bazzite Dux Niri: Rollback / Uninstaller
# Restores pure Noctalia session and removes Dux Shell session entrypoints
# ==============================================================================
set -euo pipefail

log_info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
log_ok()   { echo -e "\033[1;32m[OK]\033[0m $*"; }

log_info "Removing Dux Shell session entrypoints..."

# 1. Remove Wayland session entry
sudo rm -f /usr/local/share/wayland-sessions/niri-dux.desktop
log_ok "Removed /usr/local/share/wayland-sessions/niri-dux.desktop"

# 2. Remove session binaries
sudo rm -f /usr/local/bin/niri-session-dux
rm -f "${HOME}/.local/bin/niri-session-dux"
log_ok "Removed niri-session-dux binaries."

# 3. Optional package unlayering
if [[ "${1:-}" == "--purge-packages" ]]; then
    if command -v rpm-ostree >/dev/null 2>&1; then
        log_info "Unlayering Dux packages..."
        sudo rpm-ostree uninstall --apply-live dms dms-cli dux-calendar dux-gop dux-search quickshell matugen cava || true
        log_ok "Dux packages unlayered."
    fi
else
    log_info "Packages retained. Pass --purge-packages to unlayer Dux RPM packages."
fi

log_ok "Rollback complete. System returned to default Niri (Noctalia) and KDE Plasma."
