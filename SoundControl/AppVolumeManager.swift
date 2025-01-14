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
            mSelector: kAudioDevicePropertyVolumeScalar,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectSetPropertyData(deviceID, &address, 0, nil, volumeSize, &scalarVolume)
        if status != noErr {
            print("Falha ao ajustar o volume do dispositivo.")
        }
    }

    static func getOutputDevice(for pid: pid_t) -> AudioObjectID? {
        let defaultDevice = getDefaultOutputDevice()
        guard defaultDevice != kAudioObjectUnknown else {
            print("Dispositivo de saída padrão não encontrado.")
            return nil
        }

        var streamListSize: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioObjectPropertyElementMain,
            mScope: kAudioDevicePropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyDataSize(defaultDevice, &address, 0, nil, &streamListSize)
        if status != noErr || streamListSize == 0 {
            print("Não foi possível obter informações sobre os fluxos de áudio.")
            return nil
        }

        let streamCount = Int(streamListSize / UInt32(MemoryLayout<AudioStreamID>.size))
        var streamList = [AudioStreamID](repeating: AudioStreamID(0), count: streamCount)

        let status2 = AudioObjectGetPropertyData(defaultDevice, &address, 0, nil, &streamListSize, &streamList)
        if status2 != noErr {
            print("Erro ao obter os fluxos de áudio.")
            return nil
        }
        
        let kAudioStreamPropertyOwningPID: AudioObjectPropertySelector = AudioObjectPropertySelector(kAudioStreamPropertyVirtualFormat) + 1

        for stream in streamList {
            var owningPID: pid_t = 0
            var pidSize = UInt32(MemoryLayout.size(ofValue: owningPID))
            var pidAddress = AudioObjectPropertyAddress(
                mSelector: kAudioStreamPropertyOwningPID,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )

            let pidStatus = AudioObjectGetPropertyData(stream, &pidAddress, 0, nil, &pidSize, &owningPID)
            if pidStatus == noErr && owningPID == pid {
                return stream
            }
        }

        print("Nenhum fluxo encontrado para o PID \(pid).")
        return nil
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

        if status != noErr {
            print("Erro ao obter o dispositivo de saída padrão: \(status)")
            return kAudioObjectUnknown
        }

        print("Dispositivo de saída padrão encontrado: \(deviceID)")
        return deviceID
    }

}
