//
//  AudioHelper.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//

import Foundation
import CoreAudio
import AppKit

class AudioHelper {
    static func getAppsPlayingAudio() -> [RunningApp] {
        var runningApps: [RunningApp] = []
        let deviceID = getDefaultOutputDevice()
        if deviceID == kAudioObjectUnknown {
            print("Nenhum dispositivo de saída padrão encontrado.")
            return runningApps
        }

        let workspace = NSWorkspace.shared
        let runningApplications = workspace.runningApplications

        for app in runningApplications {
            if isAppPlayingAudio(app: app) {
                let runningApp = RunningApp(appName: app.localizedName ?? "App Desconhecido",
                                            pid: app.processIdentifier,
                                            volume: 1.0,
                                            isMuted: false)
                runningApps.append(runningApp)
                print("App encontrado: \(runningApp.appName)")
            }
        }

        return runningApps
    }

    // encontra o aplicativo pelo nome
    private static func findAppByName(_ name: String) -> NSRunningApplication? {
        let workspace = NSWorkspace.shared
        return workspace.runningApplications.first { $0.localizedName == name }
    }

    // verifica se o aplicativo está reproduzindo áudio
    private static func isAppPlayingAudio(app: NSRunningApplication) -> Bool {
        let audioApps = ["Spotify", "Safari", "YouTube", "Google Chrome", "Firefox"]
        
        if let appName = app.localizedName {
            if audioApps.contains(appName) {
                return true
            }
        }
        
        return false
    }

    private static func getDefaultOutputDevice() -> AudioObjectID {
        var deviceID = AudioObjectID(kAudioObjectUnknown)
        var size = UInt32(MemoryLayout.size(ofValue: deviceID))
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioHardwarePropertyDefaultOutputDevice,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &deviceID)
        return (status == noErr) ? deviceID : kAudioObjectUnknown
    }
}
