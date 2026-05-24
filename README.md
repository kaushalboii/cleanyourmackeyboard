# CleanMacKeyboard ⌨️🛡️

A modern, premium macOS utility that locks your keyboard so you can safely clean it without triggering accidental keypresses, system shortcuts, or media actions. It features an interactive, glassmorphic real-time keyboard visualizer designed to match Apple's modern keyboard layout.

---

## ✨ Features

- **🔒 Full Keyboard Interception:** Completely blocks standard keys, system shortcuts (like `Cmd+Tab`, `Space`), and hardware keys (brightness, volume, playback, mission control) from reaching macOS.
- **✨ Apple-Aesthetic Visualizer:** A stunning, premium dark/glassmorphic keyboard layout that replicates standard MacBook/Apple keyboard designs.
- **⬜ Real-time Press Feedback:** Keys light up in sleek white in real-time as you press them, letting you verify that keys are physically working while keeping them completely blocked.
- **⚡ Hardware Key Mapping:** Custom mapping logic intercepts Apple Silicon hardware keycodes (`F1-F12`, `fn/Globe` key, and special audio/brightness control signals).
- **🛡️ Premium Security UI:** A clean interface showing locked/unlocked states and a live counter of blocked keypresses.

---

## 🛠️ Technology Stack & Architecture

- **UI Framework:** SwiftUI with glassmorphic visuals (`NSVisualEffectView` wrapper).
- **Key Interception:** Low-level event tap (`CGEvent.tapCreate`) for `.cgSessionEventTap` to intercept system-wide `keyDown`, `keyUp`, `flagsChanged`, and `NX_SYSDEFINED` (system control) events.
- **Sandbox Configuration:** Sandbox is disabled (`ENABLE_APP_SANDBOX = NO`) to permit low-level global system-wide key observation and Accessibility database access.

---

## 🚀 How to Build & Run

### Prerequisites
- macOS 14.0 or newer
- Xcode 15.0 or newer

### Setup & Run
1. Open the project in Xcode:
   ```bash
   open cleanyourmackeyboard.xcodeproj
   ```
2. Press **▶ Run** (or `Cmd + R`) in Xcode to compile and build.
3. Click the **"Grant System Access"** button in the app UI to register with macOS Accessibility settings.

---

## 🔑 Troubleshooting Accessibility Permissions

Because `CleanMacKeyboard` intercepts keystrokes globally, macOS requires **Accessibility Access**. If the permission prompt does not appear, or the app doesn't show up in your System Settings, follow these simple developer reset steps:

1. **Quit the application completely** (Cmd + Q or stop the task in Xcode).
2. Open your Terminal and reset the Privacy (TCC) database for the app:
   ```bash
   tccutil reset Accessibility com.kaushal.cleanyourmackeyboard
   ```
3. Re-run the app from Xcode.
4. Click **"Grant System Access"** in the app. The native macOS permission popup will appear, and the app will automatically list itself under **System Settings > Privacy & Security > Accessibility**.
5. Enable the toggle next to **CleanMacKeyboard**, and you are ready to go!

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).
