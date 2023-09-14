//
//  DmAudioSession.swift
//  DramAds
//
//  Created by Khoren Asatryan on 10.09.23.
//

import Foundation
import MediaPlayer

class DmAudioSession {
    
    private static var isActive: Bool = false
    
    static func setActive() throws {
        guard self.isActive else {
            return
        }
        self.isActive = true
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .default)
        try audioSession.setActive(true)
    }
    
}
