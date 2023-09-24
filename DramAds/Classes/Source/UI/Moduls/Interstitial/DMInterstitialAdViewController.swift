//
//  DMInterstitialAdViewController.swift
//  DramAds
//
//  Created by Khoren Asatryan on 24.09.23.
//

import UIKit

class DMInterstitialAdViewController: UIViewController {
    
    private var ad: DM.InterstitialAD!
    
}

extension DMInterstitialAdViewController {
    
    class func create(ad: DM.InterstitialAD) -> UIViewController {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: DM.bundle)
        let result = storyboard.instantiateViewController(withIdentifier: "DMInterstitialAdViewControllerID") as! DMInterstitialAdViewController
        result.ad = ad
        return result
    }
    
}
