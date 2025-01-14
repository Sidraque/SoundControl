//
//  Persistence.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//

import Foundation

class PersistenceHelper {
    static func saveVolume(for app: RunningApp) {
        let key = "volume_\(app.appName)"
        UserDefaults.standard.set(app.volume, forKey: key)
    }

    static func loadVolume(for app: RunningApp) -> Float {
        let key = "volume_\(app.appName)"
        return UserDefaults.standard.float(forKey: key)
    }
}
