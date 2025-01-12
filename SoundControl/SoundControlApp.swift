//
//  SoundControlApp.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//

import SwiftUI

@main
struct SoundControlApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings { EmptyView() }
    }
}
