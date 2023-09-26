//
//  Timer.swift
//  DramAds
//
//  Created by Khoren Asatryan on 27.09.23.
//

import Foundation

class DmTimer {
    
    private var timer: Timer?
    private var fireDate: Date?
    
    let backgroundWorking: Bool
    private(set) var duration: TimeInterval = .zero
    private var callBack: ((TimeInterval) -> Void)?
    
    init(backgroundWorking: Bool = true) {
        self.backgroundWorking = backgroundWorking
        self.addNotifications()
    }
    
    func fire(interval: TimeInterval, repeats: Bool = true, block: @escaping (TimeInterval) -> Void) {
        self.fireDate = Date()
        self.callBack = block
        self.timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: repeats) { [weak self] t in
            guard let weakSelf = self, (UIApplication.shared.applicationState == .active || weakSelf.backgroundWorking) == true  else {
                return
            }
            if weakSelf.fireDate == nil {
                weakSelf.fireDate = Date()
            }
            weakSelf.duration = (weakSelf.fireDate?.distance(to: Date()) ?? .zero) + weakSelf.duration
            block(weakSelf.duration)
            weakSelf.fireDate = Date()
        }
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc private func didEnterBackground() {
        guard !self.backgroundWorking else {
            return
        }
        self.duration = (self.fireDate?.distance(to: Date()) ?? .zero) + self.duration
        self.fireDate = nil
        self.callBack?(self.duration)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
