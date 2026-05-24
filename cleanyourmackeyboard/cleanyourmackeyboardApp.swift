//
//  cleanyourmackeyboardApp.swift
//  cleanyourmackeyboard
//
//  Created by Vishal rao on 25/05/26.
//

import SwiftUI

@main
struct cleanyourmackeyboardApp: App {
    @StateObject private var blocker = KeyboardBlocker()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(blocker)
                .frame(width: 420, height: 515)
                .background(
                    VisualEffectView(material: .hudWindow, blendingMode: .withinWindow, state: .active)
                        .ignoresSafeArea()
                )
                .background(WindowAccessor { window in
                    window.titlebarAppearsTransparent = true
                    window.titleVisibility = .hidden
                    window.isMovableByWindowBackground = true
                    
                    // Style window buttons beautifully
                    window.standardWindowButton(.miniaturizeButton)?.isHidden = true
                    window.standardWindowButton(.zoomButton)?.isHidden = true
                    
                    // Set window floating level depending on lock state
                    if blocker.isLocked {
                        window.level = .floating
                    } else {
                        window.level = .normal
                    }
                    
                    window.backgroundColor = .clear
                    window.isOpaque = false
                    window.hasShadow = true
                })
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
    }
}. 
