//
//  AppVolumeManager.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//

import Foundation
import CoreAudio

class AppVolumeManager {
    static func setVolume(for app: RunningApp, to volume: Float) {
        guard let deviceID = getOutputDevice(for: app.pid) else {
            print("Não foi possível encontrar o dispositivo de áudio para o aplicativo \(app.appName).")
            return
        }
        
        setDeviceVolume(deviceID, volume: volume)
    }

    static func setDeviceVolume(_ deviceID: AudioObjectID, volume: Float) {
        var scalarVolume = volume
        let volumeSize = UInt32(MemoryLayout.size(ofValue: scalarVolume))
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyVolumeScalar, // Substituído aqui
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectSetPropertyData(deviceID, &address, 0, nil, volumeSize, &scalarVolume)
        if status != noErr {
            print("Falha ao ajustar o volume do dispositivo.")
        }
    }


    static func getOutputDevice(for pid: pid_t) -> AudioObjectID? {
        return nil 
    }
}
