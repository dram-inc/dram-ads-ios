//
//  DMPLayer.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 09.09.23.
//

import AVKit

protocol DMPlayerDelegate: AnyObject {
    func player(didChangeTime player: DMPlayer, time: TimeInterval)
    func player(didChangeStatus player: DMPlayer, status: DMPlayer.Status)
    func player(didChangeReadyToPlay player: DMPlayer, isReadyToPlay: Bool)
    func player(didChangeLoading player: DMPlayer, isLoading: Bool)
    func player(didFinishPlaying player: DMPlayer)
    func player(didReceiveError player: DMPlayer, error: IDMError)
}

extension DMPlayerDelegate {
    func player(didChangeTime player: DMPlayer, time: TimeInterval) {}
    func player(didChangeStatus player: DMPlayer, status: DMPlayer.Status) {}
    func player(didChangeReadyToPlay player: DMPlayer, isReadyToPlay: Bool) {}
    func player(didChangeLoading player: DMPlayer, isLoading: Bool) {}
    func player(didFinishPlaying player: DMPlayer) {}
    func player(didReceiveError player: DMPlayer, error: IDMError) {}
}

class DMPlayer {
    
    let player = AVPlayer()
    private var timeObserver: TimeObserver?
    weak var delegate: DMPlayerDelegate?
    
    private let timeObservers = DM.WeakArray<DMPlayerDelegate>()
    
    init() {
        self.setup()
    }
    
    func play() {
        self.player.play()
    }
    
    func pause() {
        self.player.pause()
    }
    
    func stop() {
        self.replace(item: nil)
    }
    
    func replace(url: URL?) {
        guard let url = url else {
            self.player.replaceCurrentItem(with: nil)
            return
        }
        let asset = AVURLAsset(url: url)
        self.replace(asset: asset)
    }
    
    func replace(asset: AVAsset?) {
        guard let asset = asset else {
            self.player.replaceCurrentItem(with: nil)
            return
        }
        let item = AVPlayerItem(asset: asset)
        self.replace(item: item)
    }
    
    func replace(item: AVPlayerItem?) {
        self.timeObserver?.willReplaceed(item: item)
        self.player.replaceCurrentItem(with: item)
    }
    
    func seek(to time: TimeInterval, completionHandler: ((Bool) -> Void)? = nil) {
        let seekTime = CMTime(seconds: time, preferredTimescale: 1000)
        self.player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { end in
            completionHandler?(end)
        })
    }
    
    func add(time observer: DMPlayerDelegate) {
        self.timeObservers.addObject(observer)
    }
    
    func remove(time observer: DMPlayerDelegate) {
        self.timeObservers.removeObject(observer)
    }
    
    //MARK: Private func
        
    private func setup() {
        self.timeObserver = TimeObserver(player: self.player)
        self.timeObserver?.delegate = self
    }
    
    deinit {
        self.timeObserver?.clear()
    }
    
}

extension DMPlayer: DMPlayerTimeObserverDelegate {
    
    func timeObserver(didChangeTime timeObserver: DMPlayer.TimeObserver, time: TimeInterval) {
        self.delegate?.player(didChangeTime: self, time: time)
        self.timeObservers.forEach({ $0.player(didChangeTime: self, time: time) })
    }
    
    func timeObserver(didChangeStatus timeObserver: DMPlayer.TimeObserver, status: DMPlayer.Status) {
        self.delegate?.player(didChangeStatus: self, status: status)
        self.timeObservers.forEach({ $0.player(didChangeStatus: self, status: status) })
    }
    
    func timeObserver(didChangeReadyToPlay timeObserver: TimeObserver, isReadyToPlay: Bool) {
        self.delegate?.player(didChangeReadyToPlay: self, isReadyToPlay: isReadyToPlay)
        self.timeObservers.forEach({ $0.player(didChangeReadyToPlay: self, isReadyToPlay: isReadyToPlay )})
    }
    
    func timeObserver(didChangeLoading timeObserver: DMPlayer.TimeObserver, isLoading: Bool) {
        self.delegate?.player(didChangeLoading: self, isLoading: isLoading)
        self.timeObservers.forEach({ $0.player(didChangeLoading: self, isLoading: isLoading )})
    }
    
    func timeObserver(didFinishPlaying timeObserver: DMPlayer.TimeObserver) {
        self.delegate?.player(didFinishPlaying: self)
        self.timeObservers.forEach({ $0.player(didFinishPlaying: self )})
    }
    
    func timeObserver(didReceiveError timeObserver: DMPlayer.TimeObserver, error: IDMError) {
        self.delegate?.player(didReceiveError: self, error: error)
        self.timeObservers.forEach({ $0.player(didReceiveError: self, error: error )})
    }
    
}

extension DMPlayer {
    
    enum Status: Int {
        case stopped = 0
        case playing
        case paused
    }
    
    var status: Status {
        return self.timeObserver?.status ?? .stopped
    }
    
    var isLoading: Bool {
        return self.timeObserver?.isLoading ?? false
    }
    
    var isReadyToPlay: Bool {
        return self.timeObserver?.isReadyToPlay ?? false
    }
    
    var duration: TimeInterval {
        guard self.isReadyToPlay else {
            return .zero
        }
        return self.player.currentItem?.duration.seconds ?? .zero
    }
    
    var currentTime: TimeInterval {
        guard self.isReadyToPlay else {
            return .zero
        }
        return self.player.currentItem?.currentTime().seconds ?? .zero
    }
    
    var currentAvItem: AVPlayerItem? {
        return self.player.currentItem
    }
        
}
