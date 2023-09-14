//
//  DMPlayerTimeObserver.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 09.09.23.
//

import AVKit

protocol DMPlayerTimeObserverDelegate: AnyObject {
    func timeObserver(didChangeTime timeObserver: DMPlayer.TimeObserver, time: TimeInterval)
    func timeObserver(didChangeStatus timeObserver: DMPlayer.TimeObserver, status: DMPlayer.Status)
    func timeObserver(didChangeReadyToPlay timeObserver: DMPlayer.TimeObserver, isReadyToPlay: Bool)
    func timeObserver(didChangeLoading timeObserver: DMPlayer.TimeObserver, isLoading: Bool)
    func timeObserver(didFinishPlaying timeObserver: DMPlayer.TimeObserver)
    func timeObserver(didReceiveError timeObserver: DMPlayer.TimeObserver, error: IDMError)
}

extension DMPlayerTimeObserverDelegate {
    func timeObserver(didChangeTime timeObserver: DMPlayer.TimeObserver, time: TimeInterval) {}
    func timeObserver(didChangeStatus timeObserver: DMPlayer.TimeObserver, status: DMPlayer.Status) {}
    func timeObserver(didChangeReadyToPlay timeObserver: DMPlayer.TimeObserver, isReadyToPlay: Bool) {}
    func timeObserver(didChangeLoading timeObserver: DMPlayer.TimeObserver, isLoading: Bool) {}
    func timeObserver(didFinishPlaying timeObserver: DMPlayer.TimeObserver) {}
    func timeObserver(didReceiveError timeObserver: DMPlayer.TimeObserver, error: IDMError) {}
}

extension DMPlayer {
    
    class TimeObserver: NSObject {
       
        private weak var player: AVPlayer?
        weak var delegate: DMPlayerTimeObserverDelegate?
       
        private var observerToken: Any?
        private(set) var isLoading: Bool = false
        private(set) var status: DMPlayer.Status = .stopped
        private(set) var isReadyToPlay: Bool = false
        
        private var registredItem: AVPlayerItem?
        
        init(player: AVPlayer?) {
            self.player = player
            super.init()
            DispatchQueue.main.async { [weak self] in
                self?.setup()
            }
        }
        
        func willReplaceed(item: AVPlayerItem?) {
            DispatchQueue.main.async { [weak self] in
                self?.replaceStatusObserver(item: item)
                self?.updateStatus()
            }
        }
        
        func clear() {
            NotificationCenter.default.removeObserver(self)
            self.replaceStatusObserver(item: nil)
            self.player?.removeObserver(self, forKeyPath: "timeControlStatus", context: nil)
            if let observerToken = self.observerToken {
                self.player?.removeTimeObserver(observerToken)
            }
        }
        
        //MARK: override func
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            
            if object as AnyObject? === self.player {
                if keyPath == "timeControlStatus" {
                    DispatchQueue.main.async { [weak self] in
                        self?.updateStatus()
                    }
                }
            } else if object as AnyObject? === self.player?.currentItem {
                if keyPath == "status" {
                    DispatchQueue.main.async { [weak self] in
                        self?.updateStatus()
                    }
                }
            }
        }
        
        private func setup() {
            self.addNotifications()
            self.addTimeControlStatus()
            self.addTimer()
        }
        
        private func addNotifications() {
            let center = NotificationCenter.default
            center.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        private func addTimeControlStatus() {
            self.player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        }
        
        private func replaceStatusObserver(item: AVPlayerItem?) {
            if let registredItem = self.registredItem {
                registredItem.removeObserver(self, forKeyPath: "status", context: nil)
            }
            guard let item = item else {
                self.registredItem = nil
                return
            }
            item.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
            self.registredItem = item
        }
        
        private func addTimer() {
            let interval = CMTimeMake(value: 1, timescale: 10)
            self.observerToken = self.player?.addPeriodicTimeObserver(forInterval: interval, queue: .main, using: { [weak self] (time) in
                self?.didChangeTime(time: time)
            })
        }
        
        // MARK: - Events
        
        private func didChangeIsLoading(isLoading: Bool) {
            guard self.isLoading != isLoading else {
                return
            }
            self.isLoading = isLoading
            self.delegate?.timeObserver(didChangeLoading: self, isLoading: isLoading)
        }
        
        private func didChangeStatus(status: DMPlayer.Status) {
            guard self.status != status else {
                return
            }
            self.status = status
            self.delegate?.timeObserver(didChangeStatus: self, status: status)
        }
        
        private func didChangeIsReadyToPlay(isReadyToPlay: Bool) {
            guard self.isReadyToPlay != isReadyToPlay else {
                return
            }
            self.isReadyToPlay = isReadyToPlay
            self.delegate?.timeObserver(didChangeReadyToPlay: self, isReadyToPlay: isReadyToPlay)
        }
        
        private func updateStatus() {
            if let error = self.player?.currentItem?.error {
                self.delegate?.timeObserver(didReceiveError: self, error: DM.DMError.error(error: error))
            }
            guard let registredItem = self.registredItem else {
                self.didChangeIsLoading(isLoading: false)
                self.didChangeStatus(status: .stopped)
                return
            }
            
            let isReadyToPlay = registredItem.status == .readyToPlay
            
            let isLoading = self.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate || registredItem.status == .unknown
            
            self.didChangeIsReadyToPlay(isReadyToPlay: isReadyToPlay)
            
            self.didChangeIsLoading(isLoading: isLoading)
            switch self.player?.timeControlStatus {
            case .playing:
                self.didChangeStatus(status: .playing)
            case .paused:
                self.didChangeStatus(status: .paused)
            default:
                break
            }
        }
        
        private func didChangeTime(time: CMTime) {
            self.delegate?.timeObserver(didChangeTime: self, time: time.seconds)
        }
        
        // MARK: - Notifications
        
        @objc private func playerDidFinishPlaying(note: Notification) {
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self, note.object as? NSObject == weakSelf.player?.currentItem else {
                    return
                }
                self?.updateStatus()
                self?.delegate?.timeObserver(didFinishPlaying: weakSelf)
            }
        }
        
    }
    
}
