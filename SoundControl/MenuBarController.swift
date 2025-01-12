//
//  MenuBarController.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//

import Cocoa
import SwiftUI

class MenuBarController: ObservableObject {
    @Published var runningApps: [RunningApp] = []
    private var menuBuilder: MenuBuilder!

    init() {
        self.menuBuilder = MenuBuilder()
        self.menuBuilder.attach(controller: self)
        
        DispatchQueue.main.async {
            self.menuBuilder.setupMenuBar()
        }
        
        DispatchQueue.main.async {
            self.updateRunningApps()
        }
    }

    func updateRunningApps() {
        runningApps = AudioHelper.getAppsPlayingAudio()

        DispatchQueue.main.async {
            self.menuBuilder.refreshMenu()
        }

        for index in runningApps.indices {
            runningApps[index].volume = PersistenceHelper.loadVolume(for: runningApps[index])
        }
    }

    func adjustVolume(for appName: String, to volume: Float) {
        guard let index = runningApps.firstIndex(where: { $0.appName == appName }) else { return }
        runningApps[index].volume = volume
        AppVolumeManager.setVolume(for: runningApps[index], to: volume)
        PersistenceHelper.saveVolume(for: runningApps[index])
    }

    func toggleMute(for appName: String) {
        guard let index = runningApps.firstIndex(where: { $0.appName == appName }) else { return }
        runningApps[index].isMuted.toggle()
        let newVolume: Float = runningApps[index].isMuted ? 0 : 1
        adjustVolume(for: appName, to: newVolume)
    }
}
