# Bazzite Dux Niri 🌌

**Run Dux Modular Shell (DMS) alongside Noctalia on Bazzite Linux with Niri Wayland Compositor. Keep KDE Plasma 100% untouched.**

A modular, reproducible configuration and deployment suite designed for running **Dux Modular Shell** beside **Noctalia** on **Bazzite Linux (KDE Plasma Edition)**. Features dual-session display manager switching, Google Calendar synchronization, native KDE service reuse (Konsole, Dolphin, KWallet), and `dux-gop` hardware monitoring for AMD Ryzen 9 6900HX and Radeon 680M hardware.

---

## Architecture: Three Environments, Zero Conflicts

```
                        ┌───────────────────────────────┐
                        │      SDDM / Login Screen      │
                        └───────────────┬───────────────┘
                                        │
           ┌────────────────────────────┼───────────────────────────┐
           │                            │                           │
           ▼                            ▼                           ▼
┌────────────────────┐       ┌────────────────────┐      ┌────────────────────┐
│     KDE Plasma     │       │  Niri (Noctalia)   │      │ Niri (Dux Shell)   │
│  Traditional DE    │       │ Scrollable Tiles   │      │ Material 3 Desktop │
│ (100% Untouched)   │       │ Noctalia Bar & HUD │      │ DMS, dcal & dgop   │
└────────────────────┘       └────────────────────┘      └────────────────────┘
```

* **Room 1: KDE Plasma** — The factory Bazzite desktop environment remains completely unaltered and pristine as a solid daily driver or gaming session.
* **Room 2: Niri (Noctalia)** — The scrollable Wayland tiling compositor running the lightweight Noctalia shell and status bar.
* **Room 3: Niri (Dux Shell)** — The same scrollable Wayland tiling compositor running Dux Modular Shell (Quickshell runtime, Material 3 design, dynamic Matugen color theming, Dash overview, Dux Calendar, and `dgop` hardware monitoring).
* **The Hallway: The Login Screen** — Select **Niri (Noctalia)** or **Niri (Dux Shell)** directly from the session dropdown menu before entering your password.

---

## Key Features

* **Dual-Session Display Manager Integration**:
  * Implemented via `/usr/local/share/wayland-sessions/` without modifying root image files.
  * Overrides packaged Niri session entries cleanly to offer distinct, unambiguous session choices.
* **Native KDE Application Reuse**:
  * Default terminal is **Konsole** (`Mod+Return`), preserving command history, shell profiles, and native shortcuts.
  * Reuses **KDE Wallet** for encrypted credential management across both sessions.
  * Native default bindings for **Dolphin** (`Mod+E`), **Kate** (`Mod+Shift+E`), and **KCalc** (`XF86Calculator`).
* **Google Calendar Synchronization**:
  * Built-in multi-backend calendar powered by `dux-calendar` (`dcal`).
  * Seamless OAuth flow connects Google Calendar accounts directly to local SQLite storage.
  * DMS `CalendarService` connects via Unix socket to populate the Dash Overview with appointment dots and task details.
* **Hardware Telemetry & Process Management (`dux-gop`)**:
  * Integrated `/usr/bin/dgop` process and sensor monitoring daemon.
  * Directly reads telemetry from the **AMD Ryzen 9 6900HX** (16 cores, frequencies, temperatures, governors) and **AMD Radeon 680M** GPU.
  * Powers Dux Shell's real-time desktop system monitor widgets and the interactive Task Manager modal (`dms ipc call processlist focusOrToggle`).
* **Backdrop Layer Optimization**:
  * Niri layer rules route Quickshell and wallpaper blur beneath the compositor backdrop (`place-within-backdrop true`).

---

## Keybindings Quick Reference

| Shortcut | Description | Action / Target |
| :--- | :--- | :--- |
| `Mod + Return` | Open Terminal | Konsole (`/usr/bin/konsole`) |
| `Mod + B` | Open Web Browser | Brave (`com.brave.Browser`) |
| `Mod + E` | Open File Manager | Dolphin |
| `Mod + Shift + E` | Open Text Editor | Kate |
| `XF86Calculator` | Open Calculator | KCalc |
| `Mod + D` | Toggle Dash Overview | Dux Shell Overview (`dms ipc call dash toggle overview`) |
| `Mod + Alt + C` | Toggle Full Calendar | Dux Calendar Window (`dcal toggle`) |
| `Mod + Space` | Toggle App Launcher | Dux Spotlight (`dms ipc call spotlight toggle`) |
| `Mod + S` | Toggle Control Center | Dux Control Center (`dms ipc call control-center toggle`) |
| `Mod + Shift + Return` | Wallpaper Browser | Dux Dash Wallpaper Picker |
| `Mod + Shift + C` | Color Picker | Dux Color Picker Tool |
| `Mod + Shift + S` | Dux Settings GUI | DMS Settings Window |
| `Mod + V` | Clipboard Manager | Dux Clipboard History |
| `Mod + Shift + Q` | Power Menu | Dux System Power Options |
| `Mod + L` | Lock Screen | DMS Lock Screen |
| `Mod + Tab` | Workspace Overview | Niri Native Column Zoom Overview |
| `Mod + Q` | Close Window | Niri Window Action |
| `Mod + F` | Maximize Column | Niri Layout Action |
| `Mod + Shift + F` | Fullscreen Window | Niri Layout Action |

---

## Installation Guide (Bazzite / Fedora Atomic)

### 1. Automated Installation
Clone the repository and run the automated installer:

```bash
git clone https://github.com/NightBreedLabs/bazzite-dux-niri.git
cd bazzite-dux-niri
chmod +x install.sh
./install.sh
```

The script will automatically:
* Add the official `duxlabs:dms` COPR repository.
* Layer all required packages (`dms`, `dms-cli`, `quickshell`, `matugen`, `dux-search`, `cava`, `dux-calendar`, `dux-gop`) live using `rpm-ostree install --apply-live`.
* Install the session dispatchers to `/usr/local/bin/`.
* Deploy the Wayland session files to `/usr/local/share/wayland-sessions/`.
* Configure modular Niri files (`config-dux.kdl`, `autostart-dux.kdl`, `keybinds-dux.kdl`, `rules.kdl`).
* Set `"calendarBackend": "dankcal"` in DMS settings.

### 2. Connect Google Calendar
Once logged into the **Niri (Dux Shell)** session:

1. Open Konsole (`Mod+Return`) and run:
   ```bash
   dcal account add google
   ```
2. Your default web browser will open Google's OAuth consent screen. Sign in and grant calendar access.
3. Once completed, your calendars will immediately sync locally.
4. Verify upcoming events with:
   ```bash
   dcal reminders
   ```
5. Events will automatically populate the Dash Overview (`Mod+D`) and the full calendar window (`Mod+Alt+C`).

---

## Customization: Layout Modes & Desktop Widgets

### 1. Bar Layout Modes (Standard vs. Island vs. Frame)
Dux Shell supports three primary layout styles:
* **Standard**: Clean, traditional top bar flush with screen borders.
* **Island**: Floating pill bar centered on the screen.
* **Frame**: Full display bezel surrounding all edges of the monitor (`frameEnabled: true`).

To toggle between them, open **Settings** (`Mod+Shift+S`) → **Bar**, or run:
```bash
# Disable frame bezel mode:
dms ipc call settings set frameEnabled false
```

### 2. Desktop Widgets
* **Editing Widgets**: Right-click the desktop and choose **Desktop widgets**, or press `Mod+Shift+S` → **Desktop widgets**.
* **Finishing Edits**: Click the purple **`✓ Finish`** button at the bottom center of the screen (or press `Escape`) to save widget positioning and dismiss bounding boxes.
* **Deleting Widgets**: Click the small **`✕`** icon in the top-left corner of the widget box while in edit mode.

---

## Rollback & Uninstallation

To remove Dux Shell session entrypoints and restore a pure Noctalia setup:

```bash
cd bazzite-dux-niri
chmod +x uninstall.sh
./uninstall.sh

# To also unlayer all Dux RPM packages:
./uninstall.sh --purge-packages
```

---

## License

MIT License — Copyright (c) 2026 NightBreedLabs.
