#!/usr/bin/env bash
# ==============================================================================
# Bazzite Dux Niri: Automated Installer
# Dual-Session Dux Modular Shell (DMS) alongside Noctalia on Bazzite Linux
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.config/bazzite-dux-backup-$(date +%Y%m%d_%H%M%S)"

log_info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
log_ok()   { echo -e "\033[1;32m[OK]\033[0m $*"; }
log_warn() { echo -e "\033[1;33m[WARN]\033[0m $*"; }
log_err()  { echo -e "\033[1;31m[ERROR]\033[0m $*"; }

log_info "Starting Bazzite Dux Niri installation..."

# 1. Host check
if [[ ! -f /etc/os-release ]] || ! grep -qiE 'bazzite|fedora' /etc/os-release; then
    log_warn "This installer is optimized for Bazzite / Fedora Atomic, but proceeding anyway."
fi

# 2. Backup existing Niri configs
mkdir -p "$BACKUP_DIR"
if [[ -d "${HOME}/.config/niri" ]]; then
    cp -r "${HOME}/.config/niri" "$BACKUP_DIR/niri"
    log_ok "Backed up existing Niri config to $BACKUP_DIR/niri"
fi

# 3. Add COPR repo if missing
COPR_REPO="/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:duxlabs:dms.repo"
if [[ ! -f "$COPR_REPO" ]]; then
    log_info "Configuring duxlabs:dms COPR repository..."
    sudo curl -fsSL -o "$COPR_REPO" "https://copr.fedorainfracloud.org/coprs/duxlabs/dms/repo/fedora-$(rpm -E %fedora)/duxlabs-dms-fedora-$(rpm -E %fedora).repo" || {
        log_warn "Failed to download COPR repo automatically. Please verify network access."
    }
fi

# 4. Layer packages via rpm-ostree if rpm-ostree is available
if command -v rpm-ostree >/dev/null 2>&1; then
    log_info "Checking layered Dux packages..."
    sudo rpm-ostree refresh-md
    PKGS_TO_INSTALL=()
    for pkg in dms dms-cli quickshell matugen dux-search cava dux-calendar dux-gop; do
        if ! rpm -q "$pkg" >/dev/null 2>&1; then
            PKGS_TO_INSTALL+=("$pkg")
        fi
    done

    if [[ ${#PKGS_TO_INSTALL[@]} -gt 0 ]]; then
        log_info "Layering packages live: ${PKGS_TO_INSTALL[*]}"
        sudo rpm-ostree install --apply-live "${PKGS_TO_INSTALL[@]}"
        log_ok "Packages layered live successfully."
    else
        log_ok "All Dux packages are already installed."
    fi
fi

# 5. Deploy custom session scripts
log_info "Deploying session scripts to /usr/local/bin and ~/.local/bin..."
mkdir -p "${HOME}/.local/bin"
for s in niri-session-dux niri-session-noctalia switch-shell; do
    if [[ -f "${SCRIPT_DIR}/bin/$s" ]]; then
        cp "${SCRIPT_DIR}/bin/$s" "${HOME}/.local/bin/$s"
        chmod +x "${HOME}/.local/bin/$s"
        sudo cp "${SCRIPT_DIR}/bin/$s" "/usr/local/bin/$s" 2>/dev/null || true
        sudo chmod +x "/usr/local/bin/$s" 2>/dev/null || true
    fi
done

# 6. Deploy Wayland session entries
log_info "Deploying display manager session entries to /usr/local/share/wayland-sessions..."
sudo mkdir -p /usr/local/share/wayland-sessions
for w in niri.desktop niri-dux.desktop; do
    if [[ -f "${SCRIPT_DIR}/desktop/$w" ]]; then
        sudo cp "${SCRIPT_DIR}/desktop/$w" "/usr/local/share/wayland-sessions/$w"
    fi
done

# 7. Deploy Niri configuration files
log_info "Deploying modular Niri configs..."
mkdir -p "${HOME}/.config/niri/cfg"

# Copy main config if missing or config-dux.kdl
cp "${SCRIPT_DIR}/configs/niri/config-dux.kdl" "${HOME}/.config/niri/config-dux.kdl"
for f in autostart-common.kdl autostart-dux.kdl keybinds-dux.kdl rules.kdl; do
    if [[ -f "${SCRIPT_DIR}/configs/niri/cfg/$f" ]]; then
        cp "${SCRIPT_DIR}/configs/niri/cfg/$f" "${HOME}/.config/niri/cfg/$f"
    fi
done

# 8. Configure DMS Settings
mkdir -p "${HOME}/.config/dms"
DMS_SETTINGS="${HOME}/.config/dms/settings.json"
if [[ ! -f "$DMS_SETTINGS" ]]; then
    cp "${SCRIPT_DIR}/configs/dms/settings.json" "$DMS_SETTINGS"
    log_ok "Created default DMS settings.json."
else
    # Ensure calendarBackend is dankcal
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json
try:
    with open('$DMS_SETTINGS', 'r') as f:
        data = json.load(f)
    data['calendarBackend'] = 'dankcal'
    with open('$DMS_SETTINGS', 'w') as f:
        json.dump(data, f, indent=2)
except Exception:
    pass
"
        log_ok "Updated DMS settings.json with calendarBackend: dankcal."
    fi
fi

# 9. Validation
if command -v niri >/dev/null 2>&1; then
    log_info "Validating Niri config-dux.kdl..."
    if niri validate -c "${HOME}/.config/niri/config-dux.kdl"; then
        log_ok "Niri Dux configuration is valid!"
    else
        log_warn "Niri config validation reported warnings; check syntax."
    fi
fi

echo
log_ok "====================================================================="
log_ok "Bazzite Dux Niri installation complete!"
log_ok "You can now log out and select 'Niri (Dux Shell)' at your login screen."
log_ok "====================================================================="
