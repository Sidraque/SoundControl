//
//  Persistence.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//

import Foundation

class PersistenceHelper {
    static func saveVolume(for app: RunningApp) {
        UserDefaults.standard.set(app.volume, forKey: app.appName)
    }

    static func loadVolume(for app: RunningApp) -> Float {
        return UserDefaults.standard.float(forKey: app.appName)
    }
}
