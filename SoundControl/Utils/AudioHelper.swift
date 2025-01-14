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

        getAudioStreams(for: deviceID)

        let workspace = NSWorkspace.shared
        let runningApplications = workspace.runningApplications

        for app in runningApplications {
            guard let appName = app.localizedName else { continue }
            print("Verificando aplicativo: \(appName)")

            if isAppPlayingAudio(app: app) {
                let runningApp = RunningApp(appName: appName,
                                            pid: app.processIdentifier,
                                            volume: 1.0,
                                            isMuted: false)
                runningApps.append(runningApp)
                print("App encontrado: \(runningApp.appName)")
            }
        }

        if let spotifyApp = findAppByName("Spotify"), isAppPlayingAudio(app: spotifyApp) {
            print("Spotify encontrado tocando áudio")
        } else {
            print("Spotify não está reproduzindo áudio ou não foi encontrado.")
        }

        return runningApps
    }

    private static func getAudioStreams(for deviceID: AudioObjectID) {
        var size: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size)
        if status != noErr {
            print("Erro ao obter tamanho dos fluxos de áudio: \(status)")
            return
        }

        let streamCount = Int(size) / MemoryLayout<AudioStreamID>.size
        print("Número de fluxos de áudio: \(streamCount)")

        guard streamCount > 0 else {
            print("Nenhum fluxo de áudio encontrado.")
            return
        }

        var streams = [AudioStreamID](repeating: 0, count: streamCount)
        let status2 = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &streams)
        if status2 != noErr {
            print("Erro ao obter fluxos de áudio: \(status2)")
            return
        }

        for stream in streams {
            print("Fluxo de áudio encontrado: \(stream)")
        }
    }

    private static func findAppByName(_ name: String) -> NSRunningApplication? {
        let workspace = NSWorkspace.shared
        return workspace.runningApplications.first { $0.localizedName == name }
    }
    
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

    private static func getSpotifyAudioStream(for pid: pid_t) -> AudioStreamID? {
        let deviceID = getDefaultOutputDevice()

        if deviceID == kAudioObjectUnknown {
            print("Dispositivo de saída padrão não encontrado.")
            return nil
        }

        var size: UInt32 = 0
        var address = AudioObjectPropertyAddress(
            mSelector: kAudioDevicePropertyStreams,
            mScope: kAudioObjectPropertyScopeOutput,
            mElement: kAudioObjectPropertyElementMain
        )

        let status = AudioObjectGetPropertyDataSize(deviceID, &address, 0, nil, &size)
        if status != noErr {
            print("Erro ao obter tamanho dos fluxos de áudio: \(status)")
            return nil
        }

        let streamCount = Int(size) / MemoryLayout<AudioStreamID>.size
        print("Número de fluxos de áudio encontrados: \(streamCount)")

        guard streamCount > 0 else {
            print("Nenhum fluxo de áudio encontrado.")
            return nil
        }

        var streams = [AudioStreamID](repeating: 0, count: streamCount)
        let status2 = AudioObjectGetPropertyData(deviceID, &address, 0, nil, &size, &streams)
        if status2 != noErr {
            print("Erro ao obter fluxos de áudio: \(status2)")
            return nil
        }
        let kAudioStreamPropertyOwningPID: AudioObjectPropertySelector = AudioObjectPropertySelector(kAudioStreamPropertyVirtualFormat) + 1
        
        for stream in streams {
            var owningPID: pid_t = 0
            var pidSize = UInt32(MemoryLayout.size(ofValue: owningPID))
            var pidAddress = AudioObjectPropertyAddress(
                mSelector: kAudioStreamPropertyOwningPID,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMain
            )

            let pidStatus = AudioObjectGetPropertyData(stream, &pidAddress, 0, nil, &pidSize, &owningPID)
            
            if pidStatus == noErr {
                print("Fluxo \(stream) pertence ao PID \(owningPID).")
                if owningPID == pid {
                    print("Fluxo encontrado para o PID \(pid).")
                    return stream
                }
            } else {
                print("Erro ao verificar PID para o fluxo \(stream): \(pidStatus)")
            }
        }

        print("Nenhum fluxo encontrado para o PID \(pid).")
        return nil
    }
}
