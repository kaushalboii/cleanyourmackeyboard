//
//  ContentView.swift
//  cleanyourmackeyboard
//
//  Created by Vishal rao on 25/05/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var blocker: KeyboardBlocker
    @State private var isHoveringLock: Bool = false
    @State private var pulseShield: Bool = false

    // Keyboard Key model to represent layout
    struct KeyItem: Identifiable {
        let id = UUID()
        let label: String
        let code: UInt16
        let width: CGFloat
    }

    // Row definitions for standard MacBook keyboard layout representation
    let functionRow: [KeyItem] = [
        KeyItem(label: "esc", code: 53, width: 26),
        KeyItem(label: "F1", code: 122, width: 22),
        KeyItem(label: "F2", code: 120, width: 22),
        KeyItem(label: "F3", code: 99, width: 22),
        KeyItem(label: "F4", code: 118, width: 22),
        KeyItem(label: "F5", code: 96, width: 22),
        KeyItem(label: "F6", code: 97, width: 22),
        KeyItem(label: "F7", code: 98, width: 22),
        KeyItem(label: "F8", code: 100, width: 22),
        KeyItem(label: "F9", code: 101, width: 22),
        KeyItem(label: "F10", code: 109, width: 22),
        KeyItem(label: "F11", code: 103, width: 22),
        KeyItem(label: "F12", code: 111, width: 22),
        KeyItem(label: "⏻", code: 999, width: 26)
    ]

    let row1: [KeyItem] = [
        KeyItem(label: "~", code: 50, width: 22),
        KeyItem(label: "1", code: 18, width: 22),
        KeyItem(label: "2", code: 19, width: 22),
        KeyItem(label: "3", code: 20, width: 22),
        KeyItem(label: "4", code: 21, width: 22),
        KeyItem(label: "5", code: 23, width: 22),
        KeyItem(label: "6", code: 22, width: 22),
        KeyItem(label: "7", code: 26, width: 22),
        KeyItem(label: "8", code: 28, width: 22),
        KeyItem(label: "9", code: 25, width: 22),
        KeyItem(label: "0", code: 29, width: 22),
        KeyItem(label: "-", code: 27, width: 22),
        KeyItem(label: "=", code: 24, width: 22),
        KeyItem(label: "delete", code: 51, width: 38)
    ]

    let row2: [KeyItem] = [
        KeyItem(label: "tab", code: 48, width: 38),
        KeyItem(label: "Q", code: 12, width: 22),
        KeyItem(label: "W", code: 13, width: 22),
        KeyItem(label: "E", code: 14, width: 22),
        KeyItem(label: "R", code: 15, width: 22),
        KeyItem(label: "T", code: 17, width: 22),
        KeyItem(label: "Y", code: 16, width: 22),
        KeyItem(label: "U", code: 32, width: 22),
        KeyItem(label: "I", code: 34, width: 22),
        KeyItem(label: "O", code: 31, width: 22),
        KeyItem(label: "P", code: 35, width: 22),
        KeyItem(label: "[", code: 33, width: 22),
        KeyItem(label: "]", code: 30, width: 22),
        KeyItem(label: "\\", code: 42, width: 28)
    ]

    let row3: [KeyItem] = [
        KeyItem(label: "caps", code: 57, width: 44),
        KeyItem(label: "A", code: 0, width: 22),
        KeyItem(label: "S", code: 1, width: 22),
        KeyItem(label: "D", code: 2, width: 22),
        KeyItem(label: "F", code: 3, width: 22),
        KeyItem(label: "G", code: 5, width: 22),
        KeyItem(label: "H", code: 4, width: 22),
        KeyItem(label: "J", code: 38, width: 22),
        KeyItem(label: "K", code: 40, width: 22),
        KeyItem(label: "L", code: 37, width: 22),
        KeyItem(label: ";", code: 41, width: 22),
        KeyItem(label: "'", code: 39, width: 22),
        KeyItem(label: "return", code: 36, width: 42)
    ]

    let row4: [KeyItem] = [
        KeyItem(label: "shift", code: 56, width: 54),
        KeyItem(label: "Z", code: 6, width: 22),
        KeyItem(label: "X", code: 7, width: 22),
        KeyItem(label: "C", code: 8, width: 22),
        KeyItem(label: "V", code: 9, width: 22),
        KeyItem(label: "B", code: 11, width: 22),
        KeyItem(label: "N", code: 45, width: 22),
        KeyItem(label: "M", code: 46, width: 22),
        KeyItem(label: ",", code: 43, width: 22),
        KeyItem(label: ".", code: 47, width: 22),
        KeyItem(label: "/", code: 44, width: 22),
        KeyItem(label: "shift", code: 60, width: 48)
    ]

    var body: some View {
        ZStack {
            // Premium background gradient glow
            BackgroundGlowView(isLocked: blocker.isLocked)
            
            VStack(spacing: 12) {
                // Header Block
                HeaderView(isLocked: blocker.isLocked, blockedCount: blocker.blockedCount)
                
                // Key Visualizer
                ZStack {
                    VStack(spacing: 4) {
                        KeyRowView(keys: functionRow)
                        KeyRowView(keys: row1)
                        KeyRowView(keys: row2)
                        KeyRowView(keys: row3)
                        KeyRowView(keys: row4)
                        BottomRowView()
                    }
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                    )
                    
                    // Overlay shield when locked
                    if blocker.isLocked {
                        LockedOverlayView(blockedCount: blocker.blockedCount)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .frame(width: 380, height: 182)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: blocker.isLocked)
                
                // Primary Control Button
                LockButtonView(isLocked: blocker.isLocked, isAccessibilityEnabled: blocker.isAccessibilityEnabled) {
                    if blocker.isAccessibilityEnabled {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                            blocker.isLocked.toggle()
                        }
                    } else {
                        blocker.openAccessibilitySettings()
                    }
                }
                
                // Accessibility Helper Card
                if !blocker.isAccessibilityEnabled {
                    AccessibilityPromptView {
                        blocker.openAccessibilitySettings()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                } else {
                    // Small subtle mouse guidance footer
                    Text("Use your Trackpad or Mouse to click and Unlock")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .padding(.top, 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.85), value: blocker.isAccessibilityEnabled)
    }
}

// MARK: - Subviews

struct BackgroundGlowView: View {
    var isLocked: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
            
            // Subtle pulsing accent spots
            Circle()
                .fill(isLocked ? Color.white : Color.cyanGlow)
                .frame(width: 250, height: 250)
                .blur(radius: 80)
                .opacity(isLocked ? 0.20 : 0.15)
                .offset(y: -40)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isLocked)
        }
        .ignoresSafeArea()
    }
}

struct HeaderView: View {
    var isLocked: Bool
    var blockedCount: Int
    
    var body: some View {
        VStack(spacing: 6) {
            Text("KEYBOARD SHIELD")
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .tracking(2.5)
                .foregroundColor(.white.opacity(0.4))
            
            HStack(spacing: 8) {
                Circle()
                    .fill(isLocked ? Color.white : Color.emerald)
                    .frame(width: 7, height: 7)
                    .shadow(color: isLocked ? Color.white : Color.emerald, radius: 4)
                
                Text(isLocked ? "LOCK ACTIVE" : "UNLOCKED & READY")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .padding(.top, 8)
    }
}

struct KeyRowView: View {
    @EnvironmentObject var blocker: KeyboardBlocker
    let keys: [ContentView.KeyItem]
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(keys) { key in
                KeyCapView(label: key.label, code: key.code, width: key.width)
            }
        }
    }
}

struct KeyCapView: View {
    @EnvironmentObject var blocker: KeyboardBlocker
    let label: String
    let code: UInt16
    let width: CGFloat
    
    var isPressed: Bool {
        blocker.activePressedKeys.contains(code)
    }
    
    var body: some View {
        Text(label)
            .font(.system(size: 8, weight: .bold, design: .rounded))
            .foregroundColor(isPressed ? .black : .white.opacity(0.85))
            .frame(width: width, height: 20)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isPressed ?
                          AnyShapeStyle(Color.white) :
                          AnyShapeStyle(Color.white.opacity(0.09)))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(isPressed ? Color.white : Color.white.opacity(0.16), lineWidth: 0.5)
            )
            .shadow(color: isPressed ? Color.white.opacity(0.8) : Color.clear, radius: 5)
            .animation(.easeOut(duration: 0.08), value: isPressed)
    }
}

struct BottomRowView: View {
    @EnvironmentObject var blocker: KeyboardBlocker
    
    var body: some View {
        HStack(spacing: 4) {
            // Fn, Ctrl, Opt, Cmd (Left side)
            KeyCapView(label: "fn", code: 999, width: 22) // Placeholders
            KeyCapView(label: "control", code: 59, width: 34)
            KeyCapView(label: "option", code: 58, width: 24)
            KeyCapView(label: "command", code: 55, width: 30)
            
            // Spacebar
            KeyCapView(label: "", code: 49, width: 114)
            
            // Cmd, Opt (Right side)
            KeyCapView(label: "command", code: 54, width: 30)
            KeyCapView(label: "option", code: 61, width: 24)
            
            // Arrow keys block
            HStack(spacing: 3) {
                KeyCapView(label: "◀", code: 123, width: 18)
                VStack(spacing: 2) {
                    KeyCapView(label: "▲", code: 126, width: 18)
                        .frame(height: 9)
                    KeyCapView(label: "▼", code: 125, width: 18)
                        .frame(height: 9)
                }
                KeyCapView(label: "▶", code: 124, width: 18)
            }
        }
    }
}

struct LockedOverlayView: View {
    var blockedCount: Int
    @State private var scalePulse = false
    
    var body: some View {
        ZStack {
            // Light glassmorphic blur overlay that keeps keys underneath visible!
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow, state: .active)
                .opacity(0.5) // Lightly translucent so keys are clearly visible under the blur!
                .cornerRadius(16)
            
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
            
            VStack(spacing: 8) {
                Spacer()
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .scaleEffect(scalePulse ? 1.08 : 0.94)
                    .shadow(color: Color.white.opacity(0.4), radius: 6)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                            scalePulse = true
                        }
                    }
                
                VStack(spacing: 3) {
                    Text("Cleaning Mode Active")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    if blockedCount > 0 {
                        Text("Blocked \(blockedCount) keystrokes")
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Capsule().fill(Color.white.opacity(0.2)))
                    } else {
                        Text("Keyboard is locked • Keys are safe to clean")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.bottom, 12)
            }
        }
    }
}

struct LockButtonView: View {
    var isLocked: Bool
    var isAccessibilityEnabled: Bool
    var action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: !isAccessibilityEnabled ? "exclamationmark.shield.fill" : (isLocked ? "lock.open.fill" : "lock.fill"))
                    .font(.system(size: 14, weight: .bold))
                
                Text(!isAccessibilityEnabled ? "Grant System Access" : (isLocked ? "UNLOCK KEYBOARD" : "LOCK KEYBOARD"))
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .tracking(1)
            }
            .foregroundColor(!isAccessibilityEnabled || isLocked ? .black : .white)
            .padding(.vertical, 14)
            .padding(.horizontal, 28)
            .frame(maxWidth: .infinity)
            .background(
                ZStack {
                    if !isAccessibilityEnabled {
                        // Clean Silver/White slab for accessibility grant button
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [Color.white, Color.white.opacity(0.9)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: Color.white.opacity(isHovered ? 0.3 : 0.15), radius: 6)
                    } else if isLocked {
                        // Pulsing silver/white button when locked
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(colors: [Color.white, Color.white.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .shadow(color: Color.white.opacity(isHovered ? 0.4 : 0.2), radius: 8)
                    } else {
                        // Standard Unlocked ready style
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
                            )
                    }
                }
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct AccessibilityPromptView: View {
    var action: () -> Void
    @State private var hoverSettings = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "hand.raised.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 16))
                    .padding(.top, 2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Permission Required")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("To block system shortcut keys (Cmd+Tab, Space, etc.) so you can clean safely, macOS requires Accessibility permission.")
                        .font(.system(size: 10.5, weight: .regular))
                        .foregroundColor(.white.opacity(0.65))
                        .lineSpacing(2)
                }
            }
            
            Button(action: action) {
                HStack {
                    Text("Open System Settings")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 14)
                .background(
                    Capsule()
                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                        .background(Color.white.opacity(hoverSettings ? 0.08 : 0.0))
                )
                .animation(.easeInOut(duration: 0.2), value: hoverSettings)
            }
            .buttonStyle(.plain)
            .onHover { hoverSettings = $0 }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
    }
}

// MARK: - Color Customizations

extension Color {
    static let emerald = Color(red: 46/255, green: 204/255, blue: 113/255)
    static let amber = Color(red: 243/255, green: 156/255, blue: 18/255)
    static let cyanGlow = Color(red: 0/255, green: 210/255, blue: 255/255)
    static let amberGlow = Color(red: 255/255, green: 170/255, blue: 0/255)
}
