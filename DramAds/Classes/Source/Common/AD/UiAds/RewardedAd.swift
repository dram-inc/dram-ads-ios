//
//  RewardedAd.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 05.09.23.
//

import UIKit

/// RewardedAdDelegate
@objc public protocol DMRewardedAdDelegate: NSObjectProtocol {
    
    /// Is called when ad starting playing
    /// - Parameters:
    ///     - ad: RewardedAd
    @objc(rewardedAdDidStartPlaying:) optional func rewardedAd(didStartPlaying ad: DM.RewardedAd)
    
    /// Is called when sended impression for ad
    /// - Parameters:
    ///     - ad: RewardedAd
    ///     - error: Request error
    @objc(rewardedAdDidSendImpression:error:) optional func rewardedAd(didSendImpression ad: DM.RewardedAd, error: DM.ADService.AdError?)
    
    /// Is called when clicked ad
    /// - Parameters:
    ///     - ad: RewardedAd
    @objc(rewardedAdDidClicked:) optional func rewardedAd(didClicked ad: DM.RewardedAd)
    
    /// Is called when  ad did completed
    /// - Parameters:
    ///     - ad: RewardedAd
    ///     - error: Request error
    @objc(rewardedAdDidCompleted:error:) optional func rewardedAd(didCompleted ad: DM.RewardedAd, error: DM.ADService.AdError?)
}

@objc public protocol DMRewardedAdUIDataSource: AnyObject {
    @objc(rewardedAdShouldAutorotate:) optional func rewardedAd(shouldAutorotate ad: DM.RewardedAd) -> Bool
    @objc(rewardedAdSupportedInterfaceOrientations:) optional func rewardedAd(supportedInterfaceOrientations ad: DM.RewardedAd) -> UIInterfaceOrientationMask
    @objc(rewardedAdPreferredInterfaceOrientationForPresentation:) optional func rewardedAd(preferredInterfaceOrientationForPresentation ad: DM.RewardedAd) -> UIInterfaceOrientation
}

public extension DM {
    
    @objc(DMRewardedAd)
    class RewardedAd: NSObject {
        
        let image: DM.Ad.Image?
        let video: DM.Ad.Video
        private let impressionUrl: URL?
        private let clickUrl: URL?
        private var isSendedImpression: Bool = false
        
        @objc public let bannerId: Int
        @objc public let placementId: Int
        @objc public let placementKey: String?
        
        @objc public weak var delegate: DMRewardedAdDelegate?
        @objc public weak var uiDataSource: DMRewardedAdUIDataSource?

        init(ad: DM.NativeAd, placementKey: String?) throws {
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
                callBack(.failure(error: DMError.notFound))
                return
            }
            
            guard let impressionUrl = self.impressionUrl else {
                callBack(.failure(error: DMError.notFound))
                return
            }
            
            self.isSendedImpression = true
            let request = DM.Request(url: impressionUrl)
            DM.shared.network.request(string: request) { [weak self] result in
                
                switch result {
                case .success(_):
                    DispatchQueue.main.async {
                        callBack(.success(result: Void()))
                        
                        guard let self = self else {
                            return
                        }
                        self.delegate?.rewardedAd?(didSendImpression: self, error: nil)
                        
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self?.isSendedImpression = false
                        callBack(.failure(error: error))
                        
                        guard let self = self else {
                            return
                        }
                        self.delegate?.rewardedAd?(didSendImpression: self, error: DM.ADService.AdError(error: error))
                    }
                }
            }
        }
        
        func adClick(callBack: @escaping DM.ResultCallBack<Void>) {
            
            guard let clickUrl = self.clickUrl, UIApplication.shared.canOpenURL(clickUrl) else {
                callBack(.failure(error: DMError.notFound))
                return
            }
            UIApplication.shared.open(clickUrl) { [weak self] end in
                guard end else {
                    callBack(.failure(error: DMError.notFound))
                    return
                }
                
                callBack(.success(result: Void()))
                guard let self = self else {
                    return
                }
                self.delegate?.rewardedAd?(didClicked: self)
            }
            
        }
        
        func addDidCompleted(error: IDMError?) {
            var myError: DM.ADService.AdError?
            if let error = error {
                myError = .init(error: error)
            }
            self.delegate?.rewardedAd?(didCompleted: self, error: myError)
        }
        
        func didStartPlaying() {
            self.delegate?.rewardedAd?(didStartPlaying: self)
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
    class func load(config: DM.AdRequest.Configuration, response: @escaping (DM.Result<DM.RewardedAd>) -> Void) -> IDMNetworkOperation? {
       
        DM.shared.adService.load(nativeAd: config) { result in
            switch result {
            case .success(let nativeAd):
                do {
                    let ad = try DM.RewardedAd(ad: nativeAd, placementKey: config.placementIdentifier)
                    response(.success(result: ad))
                } catch {
                    let error = DM.DMError.error(error: error)
                    response(.failure(error: error))
                }
            case .failure(let error):
                response(.failure(error: error))
            }
        }
    }
    
    /// Loaded RewardedAd for configuration
    /// - Parameters:
    ///   - placementKey: identifier placement
    /// - Returns: IDMNetworkOperation? for  cancel request any time
    @discardableResult
    class func load(placementKey: String, response: @escaping (DM.Result<DM.RewardedAd>) -> Void) -> IDMNetworkOperation? {
        let config = DM.AdRequest.Configuration(default: placementKey)
        return self.load(config: config, response: response)
    }

    @objc
    func show(in viewController: UIViewController) {
        let vc = DMRewardedAdViewController.create(ad: self)
        viewController.showDetailViewController(vc, sender: nil)
    }
    
}

@available (swift, obsoleted: 1)
public extension DM.RewardedAd {
    
    ///Load and return ad give placementKey
    @discardableResult
    @objc class func loadAd(placementKey: String, success: @escaping (DM.RewardedAd) -> Void, failure: @escaping (DM.ADService.AdError) -> Void) -> IDMNetworkOperation? {
        return self.load(placementKey: placementKey) { result in
            switch result {
            case .success(let ad):
                success(ad)
            case .failure(let error):
                failure(DM.ADService.AdError(error: error))
            }
        }
    }
    
    ///Load and return ad give config
    @discardableResult
    @objc class func loadAd(config: DM.AdRequest.Configuration, success: @escaping (DM.RewardedAd) -> Void, failure: @escaping (DM.ADService.AdError) -> Void) -> IDMNetworkOperation? {
        return self.load(config: config) { result in
            switch result {
            case .success(let ad):
                success(ad)
            case .failure(let error):
                failure(DM.ADService.AdError(error: error))
            }
        }
     
    }
    
}
