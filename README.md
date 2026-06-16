# <img width="45" height="45" alt="Gemini_Generated_Image_vuxpamvuxpamvuxp-removebg-preview" src="https://github.com/user-attachments/assets/2f6edc0c-0c9f-4916-9d54-eddafc64b6e3" /> CleanMacKeyboard ⌨️🛡️

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
Privacy Policy : 

https://docs.google.com/document/d/1LldiIxqF2GX2la6t7PhM9ZdJ7vGsaQlW_t2T9ajBXl4/edit?usp=sharing

---

## 📦 Releases & Distribution

You can distribute the application using two methods: automated releases via GitHub Actions or manual packaging using a local script.

### 1. Automated Releases via GitHub Actions (Recommended)
This repository includes a pre-configured GitHub Actions workflow that compiles, packages, and releases the app automatically when you create a new version tag.

1. **Tag your release** in git (e.g., version `v1.0.0`):
   ```bash
   git tag v1.0.0
   ```
2. **Push the tag** to GitHub:
   ```bash
   git push origin v1.0.0
   ```
3. GitHub Actions will trigger, compile the code on a macOS runner, package it into a `.zip` and `.dmg`, and publish them under a new GitHub Release.

---

### 2. Local Packaging (Manual Build)
If you want to package the app locally without pushing a tag:

1. Run the packaging script in the root directory:
   ```bash
   ./build_and_package.sh
   ```
2. This script compiles the project in `Release` configuration and outputs two distribution files:
   - **`CleanMacKeyboard.zip`** (compressed archive containing the `.app`)
   - **`CleanMacKeyboard.dmg`** (installable Apple disk image)
3. You can manually create a release on GitHub and upload these two files as assets.

---

## ⬇️ How to Download, Install & Use

1. Go to the **Releases** page of this GitHub repository.
2. Download **`CleanMacKeyboard.dmg`** (recommended) or `CleanMacKeyboard.zip`.
3. Open the downloaded file:
   - **For DMG:** Double-click the `.dmg` and drag the `CleanYourMacKeyboard` icon into your `/Applications` folder.
   - **For ZIP:** Extract the file and move `CleanYourMacKeyboard.app` to your `/Applications` folder.

### ⚠️ Resolving macOS Gatekeeper Warning
Because this application is not signed with a paid Apple Developer ID certificate, macOS will block it on first launch, displaying a warning that it is from an **"unidentified developer"**.

To bypass this and run the app, choose one of the following methods:

#### Method A: Right-Click (Recommended)
1. Open your `/Applications` folder.
2. **Right-click (or Control-click)** on `CleanYourMacKeyboard`.
3. Select **Open** from the context menu.
4. Click the **Open** button in the warning dialog to authorize it permanently.

#### Method B: Terminal Command (Fastest for Developers)
Open Terminal and run the following command to remove the quarantine flag:
```bash
xattr -cr /Applications/CleanYourMacKeyboard.app
```

Once opened, don't forget to **Grant System Access** (Accessibility permissions) so the app can intercept keys globally and protect your keyboard during cleaning.

---

## 📄 License
This project is open-source and available under the [MIT License](LICENSE).

