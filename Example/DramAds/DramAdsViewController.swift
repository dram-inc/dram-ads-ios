//
//  DramAdsViewController.swift
//  DramAds_Example
//
//  Created by Khoren Asatryan on 19.09.23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import UIKit
import DramAds

class DramAdsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let enviorment = DM.Enviorment(baseUrl: "https://ads.epomtestsite.com")
        DM.shared.configure(enviorment: enviorment)
    }
    
    
}
