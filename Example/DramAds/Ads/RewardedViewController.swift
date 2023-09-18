//
//  RewardedViewController.swift
//  DramAdsIosSdkExample
//
//  Created by Khoren Asatryan on 09.09.23.
//

import UIKit
import DramAds

class RewardedViewController: UIViewController {

    @IBAction private func didLoadAd(_ sender: Any) {
        self.dismiss(animated: true)
        
        //a23c4147ab4d03ecdb937b15a3c3dc60 2
        //c418065bb67183661a1249cbdebdf071 1
        
        DM.RewardedAd.load(placementKey: "c418065bb67183661a1249cbdebdf071") { [weak self] result in
            switch result {
            case .success(let ad):
                self?.show(ad: ad)
                break
            case .failure(let error):
                print(error as NSError)
                print("/////////////////")
                break
            }
        }
    
    }
    
    func show(ad: DM.RewardedAd) {
        ad.delegate = self
        ad.uiDataSource = self
        ad.show(in: self)
    }
    
}

extension RewardedViewController: DMRewardedAdDelegate {
    
    func rewardedAd(didStartPlaying ad: DM.RewardedAd) {
        print("rewardedAd didStartPlaying", ad.placementId)
    }
    
    func rewardedAd(didSendImpression ad: DM.RewardedAd, error: IDMError?) {
        print("rewardedAd didSendImpression", ad.placementId)
    }
    
    func rewardedAd(didClicked ad: DM.RewardedAd) {
        print("rewardedAd adDidClicked", ad.placementId)
    }
    
    func rewardedAd(didCompleted ad: DM.RewardedAd, error: IDMError?) {
        print("rewardedAd didCompleted", ad.placementId)
    }
    
}

extension RewardedViewController: DMRewardedAdUIDataSource {
    
    func rewardedAd(supportedInterfaceOrientations ad: DM.RewardedAd) -> UIInterfaceOrientationMask? {
        return .portrait
    }
    
}
