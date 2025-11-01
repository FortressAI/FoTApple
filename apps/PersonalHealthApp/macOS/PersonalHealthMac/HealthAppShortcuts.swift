// HealthAppShortcuts.swift
// App Shortcuts for Personal Health Mac App

import Foundation
import AppIntents
import FoTCore

@available(iOS 16.0, macOS 13.0, watchOS 9.0, *)
struct HealthAppShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        // Shortcuts temporarily disabled for macOS build
        // TODO: Implement FoTAppIntents for macOS
        return []
    }
}

