//
//  Item+CoreData.swift
//  SoundControl
//
//  Created by Sidraque Agostinho on 11/01/25.
//

import CoreData

extension Item {
    func updateVolume(_ newVolume: Float) {
        self.volume = newVolume
    }

    func mute() {
        self.isMuted = true
    }

    func unmute() {
        self.isMuted = false
    }
}
