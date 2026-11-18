# Dual-Shell Architecture: Dux Shell (DMS) Alongside Noctalia on Bazzite Niri

**Author:** NightBreedLabs  
**Target Platform:** Bazzite Linux (Fedora 45 Atomic / Ostree)  
**Hardware Target:** AMD Ryzen 9 6900HX (16 Cores), AMD Radeon 680M Graphics, 32 GiB RAM  
**Workstation Integration:** KDE Plasma (Untouched), Niri Wayland Compositor, Konsole, KWallet  
**Printer Target:** Formatted for clean monochrome printing on HP LaserJet Tank MFP 260x  

---

## 1. Architectural Overview

* **Dual-Shell Coexistence without Conflicts**:
  * Allows selecting between **Noctalia** and **Dux Shell (DMS)** directly from the display manager (SDDM) session menu upon login.
  * Leaves the default **KDE Plasma** desktop 100% untouched and available as a fallback session.
  * Reuses existing native KDE applications (Konsole as primary terminal, Dolphin for file management, Kate for text editing, and KWallet for encrypted credential storage) across both Wayland shells.
  * Preserves Bazzite's atomic immutable filesystem integrity using `rpm-ostree` package layering with live deployment (`--apply-live`).

* **Display Manager Session Entries**:
  * `/usr/local/share/wayland-sessions/niri.desktop` → Launches **Niri (Noctalia)** session.
  * `/usr/local/share/wayland-sessions/niri-dux.desktop` → Launches **Niri (Dux Shell)** session.
  * `/usr/share/wayland-sessions/niri.desktop` (packaged default) is overridden gracefully by the `/usr/local/` tree without modifying read-only root files.

---

## 2. Session Dispatchers & Entrypoints

* **Noctalia Session Dispatcher (`/usr/local/bin/niri-session-noctalia`)**:
  * Exports `XDG_CURRENT_DESKTOP="niri:KDE"` to preserve KDE portal integration.
  * Exports `NIRI_CONFIG="${HOME}/.config/niri/config-noctalia.kdl"`.
  * Spawns `niri --config "${NIRI_CONFIG}"`.

* **Dux Shell Session Dispatcher (`/usr/local/bin/niri-session-dux`)**:
  * Exports `XDG_CURRENT_DESKTOP="niri:KDE"`.
  * Exports `NIRI_CONFIG="${HOME}/.config/niri/config-dux.kdl"`.
  * Spawns `niri --config "${NIRI_CONFIG}"`.

* **Live Switcher CLI (`~/.local/bin/switch-shell`, source `bin/switch-shell`)**:
  * Switches the running shell live inside the current Niri session. It does not change which session the login screen starts by default; pick that at login.
  * Usage: `switch-shell noctalia` or `switch-shell dux` (`dms` is accepted as an alias for `dux`).
  * Running `switch-shell` with no argument **toggles** to the other shell; it is not a status check. There is no `status` subcommand.
  * To see which shell is running: `pgrep -x noctalia` or `pgrep -x dms`.

---

## 3. Modular Niri Configuration Structure

* **Common Autostart (`~/.config/niri/cfg/autostart-common.kdl`)**:
  * Shared daemon initialization across all Niri sessions.
  * Unlocks KWallet via `pam_kwallet_init` and `kwalletd6`.
  * Starts clipboard manager history (`wl-paste --watch cliphist store`).
  * Restores display layout and power management policies.

* **Noctalia Profile (`~/.config/niri/config-noctalia.kdl`)**:
  * Includes `autostart-common.kdl` and `autostart-noctalia.kdl` (`spawn-at-startup "noctalia"`).
  * Includes `keybinds-noctalia.kdl` for Noctalia IPC actions, bar widgets, and quick settings.

* **Dux Shell Profile (`~/.config/niri/config-dux.kdl`)**:
  * Includes `autostart-common.kdl` and `autostart-dux.kdl` (`spawn-at-startup "dms" "run"` and `spawn-at-startup "dcal" "run" "--session" "--hidden"`).
  * Includes `keybinds-dux.kdl` for Dux Shell IPC actions, Dash overview, and Dux Calendar.
  * Configures Quickshell backdrop layer rules in `rules.kdl`:
    * `match namespace="^quickshell$"` → `place-within-backdrop true`
    * `match namespace="dms:blurwallpaper"` → `place-within-backdrop true`

---

## 4. Keybindings for Dux Shell Profile

* **Core Applications**:
  * `Mod+Return` — Open Terminal: **Konsole** (`/usr/bin/konsole`).
  * `Mod+B` — Open Browser: **Brave** (`flatpak run com.brave.Browser`).
  * `Mod+E` — Open File Manager: **Dolphin** (`dolphin`).
  * `Mod+Shift+E` — Open Text Editor: **Kate** (`kate`).
  * `XF86Calculator` — Open Calculator: **KCalc** (`flatpak run org.kde.kcalc`).

* **Dux Shell Controls**:
  * `Mod+D` — Toggle **Dash Overview** (`dms ipc call dash toggle "overview"`).
  * `Mod+Alt+C` — Toggle **Dux Calendar App** (`dcal toggle`).
  * `Mod+Space` / `Mod+Ctrl+Return` — Toggle **Spotlight App Launcher** (`dms ipc call spotlight toggle`).
  * `Mod+S` — Toggle **Control Center** (`dms ipc call control-center toggle`).
  * `Mod+Shift+Return` — Browse Wallpapers (`dms ipc call dash toggle "wallpaper"`).
  * `Mod+Shift+C` — Color Picker (`dms ipc call color-picker toggle`).
  * `Mod+Shift+S` — Open DMS Settings GUI (`dms ipc call settings focusOrToggle`).
  * `Mod+V` — Clipboard History (`dms ipc call clipboard toggle`).
  * `Mod+Shift+Q` — Power Menu (`dms ipc call powermenu toggle`).
  * `Mod+L` / `Mod+Alt+L` — Lock Screen (`dms ipc call lock lock`).

* **Window Navigation & Layout**:
  * Preserves standard Niri window movement: `Mod+Left/Right` (focus column), `Mod+Up/Down` (focus window in column).
  * `Mod+Q` — Close Window.
  * `Mod+F` — Maximize Column.
  * `Mod+Shift+F` — Fullscreen Window.
  * `Mod+Tab` — Niri Native Workspace Overview (`toggle-overview`).

---

## 5. Software Stack & Package Installation

* **COPR Repository Configuration**:
  * Added Duxlabs official repository at `/etc/yum.repos.d/_copr:copr.fedorainfracloud.org:duxlabs:dms.repo`.
  * Refreshed metadata via `rpm-ostree refresh-md`.

* **Layered Packages (Applied Live)**:
  * `dms` (v2.1.2) — Dux Modular Shell backend and Quickshell Material 3 desktop UI.
  * `dms-cli` (v2.1.2) — Command-line management and IPC utility for DMS.
  * `quickshell` (v0.3.2) — High-performance C++/Qt6 Wayland desktop shell runtime.
  * `matugen` (v4.2.0) — Material You dynamic color palette generator.
  * `dux-search` (v2.1.1) — Fast native filesystem indexer and spotlight backend.
  * `cava` (v0.10.2) — Audio visualizer integration for media cards.
  * `dux-calendar` (`dcal`, v2.1.2) — Multi-backend desktop calendar application and daemon.
  * `dux-gop` (`dgop`, v2.1.1) — System monitoring CLI, REST API, and process telemetry daemon.

---

## 6. Google Calendar Integration (`dcal` & `dms`)

* **Background Service & Daemon**:
  * `dux-calendar` runs in daemon mode (`dcal run -d --daemon-child`).
  * Communicates with Dux Shell over a local Unix domain socket (`/run/user/1000/dankcal-<PID>.sock`).

* **OAuth Authentication**:
  * Initiated via `dcal account add google`.
  * User completes web browser consent flow; authentication tokens are stored securely in local storage.
  * All 14 user calendars and events are fetched and indexed locally into `dcal` database.

* **Dux Shell Configuration (`~/.config/dms/settings.json`)**:
  * Configured `"calendarBackend": "dankcal"`.
  * `CalendarService.qml` connects to `dcal` via `CalendarDankBackend.qml`, populating:
    * The **Dash Overview Calendar Card**: Displays a monthly grid with colored event dots for dates with appointments.
    * Day details: Clicking any date flips the card to reveal event summaries, start/end times, and reminders.
    * Standalone App: `dcal toggle` (`Mod+Alt+C`) opens the full calendar window with day, week, month, and agenda layouts.

---

## 7. System Telemetry & Process Monitoring (`dux-gop`)

* **Binary**: `/usr/bin/dgop` installed via `dux-gop` package.
* **Hardware Telemetry Support**:
  * **CPU**: AMD Ryzen 9 6900HX (16 Cores, 416-4937 MHz, temperature, per-core load, performance governor).
  * **GPU**: AMD Radeon 680M (amdgpu driver, PCI bus `0000:35:00.0`, temperature, memory usage).
  * **Memory**: 32 GiB physical RAM and swap breakdown.
* **Shell Integration**:
  * Powers Dux Shell's `DgopService.qml`.
  * Feeds real-time telemetry to Desktop System Monitor widgets and top bar resource pills.
  * Enables the Task Manager / Process List modal (`dms ipc call processlist focusOrToggle`).
* **Terminal Diagnostics**:
  * Run `dgop top` in Konsole for an interactive terminal system monitor.
  * Run `dgop cpu` or `dgop gpu` for instant hardware status reports.

---

## 8. Shell Customization: Frames, Layouts & Widgets

* **Layout Modes (Bar & Frame)**:
  * **Standard**: Clean, traditional top bar flush with screen edges.
  * **Island**: Modern floating pill bar with rounded corners.
  * **Frame**: Full desktop bezel surrounding the display edges (`frameEnabled: true`).
  * Toggle frame mode in **Settings** (`Mod+Shift+S`) → **Bar**, or via CLI:
    ```bash
    dms ipc call settings set frameEnabled false
    ```

* **Desktop Widget Management**:
  * Add widgets (Weather, Clock, System Monitor) to the wallpaper via **Settings** → **Desktop widgets** or right-clicking empty desktop space.
  * Bounding boxes with dimensions appear when in **Desktop Widget Edit Mode**.
  * Click **`✓ Finish`** at the bottom (or press `Escape`) to save widget layout and exit edit mode.
  * Click the **`✕`** icon on the top-left of any widget box to delete it from the desktop.

---

## 9. Verification & Health Audit

* **`dms doctor` Health Report**:
  * Operating System: Bazzite (x86_64 / Wayland).
  * Compositor: Niri 26.04 (Active).
  * Quickshell, Background Blur, Polkit, IdleMonitor, ShortcutInhibitor: Available.
  * Installed Dux Components: `dux-search`, `dux-calendar`, `dux-gop`, `matugen`, `cava`.
  * Overall health: 39 checks passed cleanly.

---

## 10. Maintenance & Rollback Instructions

* **To update Dux packages in the future**:
  ```bash
  sudo rpm-ostree refresh-md
  sudo rpm-ostree upgrade --apply-live
  ```
* **To rollback to pure Noctalia without Dux packages**:
  ```bash
  sudo rpm-ostree uninstall --apply-live dms dms-cli dux-calendar dux-gop dux-search quickshell matugen cava
  sudo rm -f /usr/local/share/wayland-sessions/niri-dux.desktop
  sudo rm -f /usr/local/bin/niri-session-dux
  ```
