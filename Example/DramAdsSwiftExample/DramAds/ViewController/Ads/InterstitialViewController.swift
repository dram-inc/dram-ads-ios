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
        DM.InterstitialAD.load(placementKey: "a1d76e5f0ed9bc739e711e9fd2382954") { result in
            switch result {
            case .success(let result):
                result.show(in: self)
            case .failure(let error):
                print("")
            }
        }
    }
    
}
