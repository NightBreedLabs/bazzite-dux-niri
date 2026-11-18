# BAZZITE DUX NIRI: OPERATIONAL & USER MANUAL

**Hardware Platform:** AMD Ryzen 9 6900HX (16 Cores), AMD Radeon 680M, 32 GiB RAM  
**Operating System:** Bazzite Linux 45 (Fedora Atomic / ostree)  
**Target Printer:** HP LaserJet Tank MFP 260x (Monochrome / High Contrast Layout)  
**Project:** NightBreedLabs / Bazzite Dux Niri  
**Version:** 1.0.0 (November 2026)  

---

## 1. SYSTEM OVERVIEW & ARCHITECTURE

* **Triple-Desktop Coexistence**:
  * **KDE Plasma**: The standard Bazzite desktop environment remains 100% untouched.
  * **Niri (Noctalia)**: The scrolling Wayland compositor running the Noctalia shell.
  * **Niri (Dux Shell)**: The scrolling Wayland compositor running Dux Modular Shell (DMS).
* **Login Selection**:
  * You can select your session from the Display Manager (SDDM) menu prior to sign-in.
  * Session entrypoints reside in `/usr/local/share/wayland-sessions/` to protect root filesystem immutability.
* **Core Application Reuse**:
  * Both Wayland sessions reuse existing native KDE Plasma components:
    * Terminal Emulator: **Konsole** (`/usr/bin/konsole`).
    * File Manager: **Dolphin** (`/usr/bin/dolphin`).
    * Text Editor: **Kate** (`/usr/bin/kate`).
    * Credential Vault: **KDE Wallet** (`kwalletd6`).

---

## 2. KEYBOARD SHORTCUTS REFERENCE TABLE

* **Core Applications**:
  * `Mod + Return` — Launch Terminal (Konsole)
  * `Mod + B` — Launch Web Browser (Brave)
  * `Mod + E` — Launch File Manager (Dolphin)
  * `Mod + Shift + E` — Launch Text Editor (Kate)
  * `XF86Calculator` — Launch Calculator (KCalc)

* **Dux Modular Shell Controls**:
  * `Mod + D` — Toggle Dash Overview (Calendar, Weather, Tasks)
  * `Mod + Alt + C` — Toggle Full Dux Calendar Application (`dcal`)
  * `Mod + Space` — Toggle Spotlight App Launcher
  * `Mod + Ctrl + Return` — Toggle Spotlight App Launcher
  * `Mod + S` — Toggle Control Center Panel
  * `Mod + Shift + Return` — Open Wallpaper Browser
  * `Mod + Shift + C` — Open Color Picker Tool
  * `Mod + Shift + S` — Open Dux Shell Settings Window
  * `Mod + V` — Open Clipboard History Popout
  * `Mod + Shift + Q` — Open System Power Menu
  * `Mod + L` — Lock Display

* **Window & Layout Management**:
  * `Mod + Q` — Close Active Window
  * `Mod + F` — Maximize Column Width
  * `Mod + Shift + F` — Toggle Fullscreen Window
  * `Mod + Tab` — Niri Window Column Overview (Zoom Out)
  * `Mod + Left / Right` — Shift Column Focus Left / Right
  * `Mod + Up / Down` — Shift Window Focus Up / Down

---

## 3. GOOGLE CALENDAR SYNCHRONIZATION

* **Architecture**:
  * Calendar backend is powered by `dux-calendar` (`dcal`).
  * Runs as a user daemon socket (`/run/user/1000/dankcal-<PID>.sock`).
  * Seamlessly connects to Google Calendar via OAuth2.
* **Adding an Account**:
  * Open Konsole (`Mod + Return`).
  * Run command: `dcal account add google`.
  * Sign in and approve read/write permissions in the browser prompt.
* **Viewing Events**:
  * **Dash Overview (`Mod + D`)**: Displays colored dots for scheduled events on the monthly grid. Click any day to see event details.
  * **Dux Calendar App (`Mod + Alt + C`)**: Opens the full interactive calendar with Day, Week, Month, and Agenda views.

---

## 4. SYSTEM MONITORING & TELEMETRY (`dux-gop`)

* **Background Engine**:
  * Telemetry is gathered by `/usr/bin/dgop` (`dux-gop` package).
  * Direct low-overhead hardware polling without external dependencies.
* **Hardware Recognition**:
  * **Processor**: AMD Ryzen 9 6900HX (Reports core clock speeds, load %, governor, and CPU package temp).
  * **Graphics**: AMD Radeon 680M (Reports driver state, PCI bus info, and memory).
  * **Memory**: Physical RAM and Swap capacity and usage.
* **Interactive CLI Usage**:
  * `dgop top` — Real-time terminal system monitor.
  * `dgop cpu` — Instant CPU hardware breakdown.
  * `dgop gpu` — GPU details and bus addressing.
* **Task Manager Modal**:
  * Access the graphical task manager at any time via:
    `dms ipc call processlist focusOrToggle`

---

## 5. DESKTOP WIDGETS & DISPLAY BEZELS

* **Bar Layout Styles**:
  * **Standard**: Conventional top bar flush with screen margins.
  * **Island**: Floating bar centered horizontally.
  * **Frame**: Full desktop bezel surrounding all screen edges.
  * Toggle frame mode via terminal:
    `dms ipc call settings set frameEnabled false`
* **Desktop Widget Editing**:
  * Add widgets via **Settings** (`Mod + Shift + S`) → **Desktop widgets**.
  * Bounding boxes with dimensions appear when in edit mode.
  * Click **`✓ Finish`** at the bottom (or press `Escape`) to save and exit.
  * Click the **`✕`** icon on the top-left of any widget to remove it.

---

## 6. MAINTENANCE & TROUBLESHOOTING

* **System Doctor Command**:
  * Verify health and component states by running:
    `dms doctor`
* **Restarting Shell Services**:
  * Reload Dux Shell backend live:
    `dms restart`
  * Reload Niri configuration live:
    `niri msg action load-config-file`
* **Switching Shell Live from Terminal** (`~/.local/bin/switch-shell`; affects the current session only, not the login default):
  * Switch to Noctalia: `switch-shell noctalia`
  * Switch to Dux Shell: `switch-shell dux`
  * Check current: `pgrep -x noctalia` or `pgrep -x dms` (there is no `switch-shell status`; running `switch-shell` with no argument toggles shells)

---

*Document compiled by NightBreedLabs for local offline reference and monochrome printing.*
