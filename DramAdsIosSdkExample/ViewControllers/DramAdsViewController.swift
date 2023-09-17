//
//  DramAdsViewController.swift
//  DramAdsIosSdkExample
//
//  Created by Khoren Asatryan on 09.09.23.
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
