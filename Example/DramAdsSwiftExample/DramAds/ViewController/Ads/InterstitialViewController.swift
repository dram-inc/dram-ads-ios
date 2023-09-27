//
//  InterstitialViewController.swift
//  DramAds_Example
//
//  Created by Khoren Asatryan on 24.09.23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DramAds

class InterstitialViewController: UIViewController {
    
    @IBAction private func didSelectLoadAd(_ sender: Any) {
        
//        "a1d76e5f0ed9bc739e711e9fd2382954"
        DM.InterstitialAd.load(placementKey: "a1d76e5f0ed9bc739e711e9fd2382954") { [weak self] result in
            switch result {
            case .success(let result):
                self?.showAd(ad: result)
            case .failure(let error):
                print(error.message ?? "")
            }
        }
    }
    
    func showAd(ad: DM.InterstitialAd) {
        ad.delegate = self
        ad.show(in: self)
    }
    
}

extension InterstitialViewController: DMInterstitialAdDelegate {
    
    func interstitialAd(didStartPlaying ad: DM.InterstitialAd) {
        print("interstitialAd didStartPlaying", ad.bannerId, ad.placementKey ?? "")
    }
    
    func interstitialAd(didSendImpression ad: DM.InterstitialAd, error: DM.ADService.AdError?) {
        print("interstitialAd didSendImpression", ad.bannerId, ad.placementKey ?? "", error?.message ?? "")
    }
    
    func interstitialAd(didClicked ad: DM.InterstitialAd) {
        print("interstitialAd didClicked", ad.bannerId, ad.placementKey ?? "")
    }
    
    func interstitialAd(didCompleted ad: DM.InterstitialAd, error: DM.ADService.AdError?) {
        print("interstitialAd didCompleted", ad.bannerId, ad.placementKey ?? "", error?.message ?? "")
    }
    
    func interstitialAd(didSkiped ad: DM.InterstitialAd) {
        print("interstitialAd didSkiped", ad.bannerId, ad.placementKey ?? "")
    }
    
}



