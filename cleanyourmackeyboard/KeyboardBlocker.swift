//
//  KeyboardBlocker.swift
//  cleanyourmackeyboard
//
//  Created by Vishal rao on 25/05/26.
//

import Cocoa
import Foundation
import Combine

class KeyboardBlocker: ObservableObject {
    @Published var isAccessibilityEnabled: Bool = false
    @Published var isLocked: Bool = false {
        didSet {
            if isLocked {
                startLocking()
            } else {
                stopLocking()
            }
        }
    }
    @Published var blockedCount: Int = 0
    @Published var activePressedKeys: Set<UInt16> = []
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var localMonitor: Any?
    private var timer: Timer?

    init() {
        checkAccessibility(prompt: false)
        startCheckingAccessibility()
        setupLocalKeyMonitor()
    }
    
    deinit {
        stopLocking()
        if let localMonitor = localMonitor {
            NSEvent.removeMonitor(localMonitor)
        }
        timer?.invalidate()
    }
    
    func checkAccessibility(prompt: Bool) {
        let options = prompt ? [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary : nil
        let trusted = AXIsProcessTrustedWithOptions(options)
        DispatchQueue.main.async {
            self.isAccessibilityEnabled = trusted
        }
    }
    
    private func startCheckingAccessibility() {
        // Poll every 1.0 seconds to auto-enable once user checks the box in System Preferences
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let trusted = AXIsProcessTrusted()
            if trusted != self.isAccessibilityEnabled {
                DispatchQueue.main.async {
                    self.isAccessibilityEnabled = trusted
                    if !trusted && self.isLocked {
                        self.isLocked = false
                    }
                }
            }
        }
    }
    
    func openAccessibilitySettings() {
        // Trigger OS Accessibility prompt first (this makes our app appear in the Accessibility list)
        checkAccessibility(prompt: true)
        
        // Open the System Preferences directly to Privacy -> Accessibility
        let urlString = "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
        if let url = URL(string: urlString) {
            NSWorkspace.shared.open(url)
        } else {
            let fallbackUrl = URL(string: "https://support.apple.com/guide/mac-help/allow-accessibility-apps-to-control-your-mac-mh43185/mac")!
            NSWorkspace.shared.open(fallbackUrl)
        }
    }
    
    private func startLocking() {
        // Make sure we have permission
        let trusted = AXIsProcessTrusted()
        if !trusted {
            checkAccessibility(prompt: true)
            DispatchQueue.main.async {
                self.isAccessibilityEnabled = false
                self.isLocked = false
            }
            return
        }
        
        guard eventTap == nil else { return }
        
        // Intercept KeyDown, KeyUp, FlagsChanged, and NX_SYSDEFINED (media keys, volume, brightness, etc.)
        let eventMask = (1 << CGEventType.keyDown.rawValue) |
                        (1 << CGEventType.keyUp.rawValue) |
                        (1 << CGEventType.flagsChanged.rawValue) |
                        (1 << 14) // 14 represents NX_SYSDEFINED events for media/hardware controls
        
        let callback: CGEventTapCallBack = { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
            guard let refcon = refcon else { return Unmanaged.passRetained(event) }
            let blocker = Unmanaged<KeyboardBlocker>.fromOpaque(refcon).takeUnretainedValue()
            
            // Block all modifier and standard keys
            if blocker.isLocked {
                DispatchQueue.main.async {
                    blocker.blockedCount += 1
                    
                    let rawType = type.rawValue
                    // Register keypress visually even when blocked so the key lights up under the frost blur!
                    if rawType == 10 || rawType == 12 { // keyDown or flagsChanged
                        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                        let uKeyCode = UInt16(keyCode)
                        blocker.activePressedKeys.insert(uKeyCode)
                        
                        // Auto-fade key highlight
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            blocker.activePressedKeys.remove(uKeyCode)
                        }
                    } else if rawType == 14 { // NX_SYSDEFINED (brightness, volume, playback hardware keys)
                        if let nsEvent = NSEvent(cgEvent: event) {
                            let subtype = nsEvent.subtype.rawValue
                            if subtype == 8 { // Subtype 8 is media key events!
                                let data = nsEvent.data1
                                let keyCode = (data & 0xFFFF0000) >> 16
                                let keyFlags = (data & 0x0000FFFF)
                                let keyState = ((keyFlags & 0xFF00) >> 8) == 0xA // 0xA is keyDown, 0xB is keyUp
                                
                                var mappedCode: UInt16 = 0
                                switch keyCode {
                                case 0: mappedCode = 111  // F12 (Volume Up)
                                case 1: mappedCode = 103  // F11 (Volume Down)
                                case 7: mappedCode = 109  // F10 (Mute)
                                case 3: mappedCode = 120  // F2 (Brightness Up)
                                case 4: mappedCode = 122  // F1 (Brightness Down)
                                case 16: mappedCode = 100 // F8 (Play/Pause)
                                case 17: mappedCode = 98  // F7 (Rewind)
                                case 18: mappedCode = 101 // F9 (Fast Forward)
                                default: break
                                }
                                
                                if mappedCode > 0 && keyState {
                                    blocker.activePressedKeys.insert(mappedCode)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        blocker.activePressedKeys.remove(mappedCode)
                                    }
                                }
                            }
                        }
                    }
                }
                // Return nil to completely consume and block the event
                return nil
            }
            
            return Unmanaged.passRetained(event)
        }
        
        let refcon = Unmanaged.passUnretained(self).toOpaque()
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: callback,
            userInfo: refcon
        )
        
        if let eventTap = eventTap {
            runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
            print("Successfully enabled global keyboard block tap")
        } else {
            print("Failed to create global event tap")
            DispatchQueue.main.async {
                self.isLocked = false
            }
        }
    }
    
    private func stopLocking() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            }
            self.eventTap = nil
            self.runLoopSource = nil
            print("Successfully disabled global keyboard block tap")
        }
    }
    
    private func setupLocalKeyMonitor() {
        // Monitor keys while app is focused/active to show interactive visuals
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { [weak self] event in
            guard let self = self else { return event }
            
            if self.isLocked {
                // If locked, consume local keys to prevent menu triggers or App shortcuts
                return nil
            }
            
            if event.type == .keyDown {
                self.activePressedKeys.insert(event.keyCode)
            } else if event.type == .keyUp {
                self.activePressedKeys.remove(event.keyCode)
            } else if event.type == .flagsChanged {
                let flags = event.modifierFlags
                
                // Track shifts, option, cmd, control keycodes
                self.updateModifierKey(flag: .shift, keyCode: 56, modifierFlags: flags)
                self.updateModifierKey(flag: .control, keyCode: 59, modifierFlags: flags)
                self.updateModifierKey(flag: .option, keyCode: 58, modifierFlags: flags)
                self.updateModifierKey(flag: .command, keyCode: 55, modifierFlags: flags)
            }
            
            return event
        }
    }
    
    private func updateModifierKey(flag: NSEvent.ModifierFlags, keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags) {
        if modifierFlags.contains(flag) {
            activePressedKeys.insert(keyCode)
        } else {
            activePressedKeys.remove(keyCode)
        }
    }
}
