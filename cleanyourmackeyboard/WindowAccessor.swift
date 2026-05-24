//
//  WindowAccessor.swift
//  cleanyourmackeyboard
//
//  Created by Vishal rao on 25/05/26.
//

import SwiftUI
import AppKit

struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            if let window = nsView.window {
                callback(window)
            }
        }
        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            callback(window)
        }
    }
}
