//
//  DMPlayerTimeCalculator.swift
//  DramAds
//
//  Created by Khoren Asatryan on 26.09.23.
//

import Foundation

extension DMPlayer {
    
    class TimeCalculator {
                
        private(set) var state = PlayerState.none
        private weak var player: DMPlayer?
        private var startPlayDate: Date?
        private var playbackDuration: TimeInterval = .zero
        
        private var changes: Changes?
        
        init(player: DMPlayer, changes: @escaping Changes) {
            self.player = player
            self.changes = changes
            player.add(time: self)
        }
        
        private func calculateState() -> PlayerState {
            guard let player = self.player else {
                return .none
            }
            switch player.status {
            case .stopped:
                return .stopped
            case .playing:
                if player.isLoading || !player.isReadyToPlay {
                    return .loading
                }
                return .playing
            case .paused:
                return .paused
            }
        }
        
        private func didChangeTime(_ time: TimeInterval) {
            if let startPlayDate = self.startPlayDate {
                let deltaTime = startPlayDate.distance(to: Date())
                self.playbackDuration = self.playbackDuration + deltaTime
                self.changes?(self.state, self.playbackDuration)
            }
            self.startPlayDate = Date()
        }
        
        private func didChangePlaying(_ isPLaying: Bool) {
            if isPLaying {
                self.startPlayDate = Date()
            } else if let startPlayDate = self.startPlayDate {
                let deltaTime = startPlayDate.distance(to: Date())
                self.playbackDuration = self.playbackDuration + deltaTime
                self.changes?(self.state, self.playbackDuration)
            }
            self.startPlayDate = nil
        }
        
        private func didChangeState() {
            let isPLaying = self.state == .playing
            self.didChangePlaying(isPLaying)
            self.changes?(self.state, self.playbackDuration)
        }
        
    }
    
}

extension DMPlayer.TimeCalculator: DMPlayerDelegate {
    
    func player(didChangeTime player: DMPlayer, time: TimeInterval) {
        self.didChangeTime(time)
    }
    
    func player(didChangeStatus player: DMPlayer, status: DMPlayer.Status) {
        let playerState = self.calculateState()
        guard self.state != playerState else {
            return
        }
        self.state = playerState
        self.didChangeState()
    }
    
    func player(didChangeReadyToPlay player: DMPlayer, isReadyToPlay: Bool) {
        let playerState = self.calculateState()
        guard self.state != playerState else {
            return
        }
        self.state = playerState
        self.didChangeState()
    }
    
    func player(didChangeLoading player: DMPlayer, isLoading: Bool) {
        let playerState = self.calculateState()
        guard self.state != playerState else {
            return
        }
        
        self.state = playerState
        self.didChangeState()
    }
    
    func player(didFinishPlaying player: DMPlayer) {
        guard self.state != .finished else {
            return
        }
        self.state = .finished
        self.didChangeState()
    }
    
    func player(didReceiveError player: DMPlayer, error: IDMError) {
        guard self.state != .error else {
            return
        }
        self.state = .error
        self.didChangeState()
    }
    
}

extension DMPlayer.TimeCalculator {
    
    typealias Changes = ((_ state: PlayerState, _ playback: TimeInterval) -> Void)
    
    enum PlayerState {
        case none
        case playing
        case paused
        case stopped
        case loading
        case finished
        case error
    }
    
}
