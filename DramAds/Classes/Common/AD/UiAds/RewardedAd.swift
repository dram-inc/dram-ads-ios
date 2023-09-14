//
//  RewardedAd.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 05.09.23.
//

import UIKit

/// RewardedAdDelegate
public protocol DMRewardedAdDelegate: AnyObject {
    
    /// Is called when ad starting playing
    /// - Parameters:
    ///     - ad: RewardedAd
    func rewardedAd(didStartPlaying ad: DM.RewardedAd)
    
    /// Is called when sended impression for ad
    /// - Parameters:
    ///     - ad: RewardedAd
    ///     - error: Request error
    func rewardedAd(didSendImpression ad: DM.RewardedAd, error: IDMError?)
    
    /// Is called when clicked ad
    /// - Parameters:
    ///     - ad: RewardedAd
    func rewardedAd(didClicked ad: DM.RewardedAd)
    
    /// Is called when  ad did completed
    /// - Parameters:
    ///     - ad: RewardedAd
    ///     - error: Request error
    func rewardedAd(didCompleted ad: DM.RewardedAd, error: IDMError?)
}

public extension DMRewardedAdDelegate {
    func rewardedAd(didStartPlaying ad: DM.RewardedAd) {}
    func rewardedAd(didSendImpression ad: DM.RewardedAd, error: IDMError?) {}
    func rewardedAd(didClicked ad: DM.RewardedAd) {}
    func rewardedAd(didCompleted ad: DM.RewardedAd, error: IDMError?) {}
}

public protocol DMRewardedAdUIDataSource: AnyObject {
    func rewardedAd(shouldAutorotate ad: DM.RewardedAd) -> Bool?
    func rewardedAd(supportedInterfaceOrientations ad: DM.RewardedAd) -> UIInterfaceOrientationMask?
    func rewardedAd(preferredInterfaceOrientationForPresentation ad: DM.RewardedAd) -> UIInterfaceOrientation?
}

public extension DMRewardedAdUIDataSource {
    
    func rewardedAd(shouldAutorotate ad: DM.RewardedAd) -> Bool? {
        return nil
    }
    
    func rewardedAd(supportedInterfaceOrientations ad: DM.RewardedAd) -> UIInterfaceOrientationMask? {
        return nil
    }
    
    func rewardedAd(preferredInterfaceOrientationForPresentation ad: DM.RewardedAd) -> UIInterfaceOrientation? {
        return nil
    }
    
}

public extension DM {
    
    class RewardedAd {
        
        let image: DM.EpomAd.Image?
        let video: DM.EpomAd.Video
        private let impressionUrl: URL?
        private let clickUrl: URL?
        private var isSendedImpression: Bool = false
        public let bannerId: Int
        public let placementId: Int
        public let placementKey: String?
        
        public weak var delegate: DMRewardedAdDelegate?
        public weak var uiDataSource: DMRewardedAdUIDataSource?

        init(ad: DM.EpomNativeAd, placementKey: String?) throws {
            guard let video = ad.videos?.first, let bannerId = ad.bannerId, let placementId = ad.placementId else {
                throw DM.ADService.AdError.configurationError
            }
            self.impressionUrl = ad.beacons?.first(where: { $0.type == .impression })?.url
            self.clickUrl = ad.clickUrl
            self.image = ad.images?.first
            self.video = video
            self.placementId = placementId
            self.bannerId = bannerId
            self.placementKey = placementKey
        }
        
        func sendImpression(callBack: @escaping DM.ResultCallBack<Void>) {
            guard !self.isSendedImpression else {
                callBack(.failure(DMError.notFound))
                return
            }
            
            guard let impressionUrl = self.impressionUrl else {
                callBack(.failure(DMError.notFound))
                return
            }
            
            
            self.isSendedImpression = true
            let request = DM.Request(url: impressionUrl)
            DM.shared.network.request(string: request) { [weak self] result in
                
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        callBack(.success(Void()))
                        
                        guard let self = self else {
                            return
                        }
                        self.delegate?.rewardedAd(didSendImpression: self, error: nil)
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.isSendedImpression = false
                        callBack(.failure(error))
                        
                        guard let self = self else {
                            return
                        }
                        self.delegate?.rewardedAd(didSendImpression: self, error: error)
                    }
                }
            }
        }
        
        func adClick(callBack: @escaping DM.ResultCallBack<Void>) {
            
            guard let clickUrl = self.clickUrl, UIApplication.shared.canOpenURL(clickUrl) else {
                callBack(.failure(DMError.notFound))
                return
            }
            UIApplication.shared.open(clickUrl) { [weak self] end in
                guard end else {
                    callBack(.failure(DMError.notFound))
                    return
                }
                
                callBack(.success(Void()))
                guard let self = self else {
                    return
                }
                self.delegate?.rewardedAd(didClicked: self)
            }
            
        }
        
        func addDidCompleted(error: IDMError?) {
            self.delegate?.rewardedAd(didCompleted: self, error: error)
        }
        
        func didStartPlaying() {
            self.delegate?.rewardedAd(didStartPlaying: self)
        }
        
    }
    
}

public extension DM.RewardedAd {

    /// Loaded RewardedAd for configuration
    /// - Parameters:
    ///   - config: is a configuration request
    ///   - response: have 2 case success with RewardedAd and failure with IDMError
    /// - Returns: IDMNetworkOperation? for  cancel request any time
    @discardableResult
    class func load(config: DM.EpomAdRequest.Configuration, response: @escaping (DM.Result<DM.RewardedAd>) -> Void) -> IDMNetworkOperation? {
       
        DM.shared.adService.load(nativeAd: config) { result in
            switch result {
            case .success(let nativeAd):
                do {
                    let ad = try DM.RewardedAd(ad: nativeAd, placementKey: config.placementIdentifier)
                    response(.success(ad))
                } catch {
                    let error = DM.DMError.error(error: error)
                    response(.failure(error))
                }
            case .failure(let error):
                response(.failure(error))
            }
        }
    }
    
    /// Loaded RewardedAd for configuration
    /// - Parameters:
    ///   - placementKey: identifier placement
    /// - Returns: IDMNetworkOperation? for  cancel request any time
    @discardableResult
    class func load(placementKey: String, response: @escaping (DM.Result<DM.RewardedAd>) -> Void) -> IDMNetworkOperation? {
        let config = DM.EpomAdRequest.Configuration(default: placementKey)
        return self.load(config: config, response: response)
    }

    func show(in viewController: UIViewController) {
        let vc = DMRewardedAdViewController.create(ad: self)
        viewController.showDetailViewController(vc, sender: nil)
    }
    
}
