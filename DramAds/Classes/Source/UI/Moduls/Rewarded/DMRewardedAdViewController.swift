//
//  RewardedAdViewController.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 08.09.23.
//

import UIKit

class DMRewardedAdViewController: UIViewController {
    
    @IBOutlet weak private var playerView: DMPlayerView!
    @IBOutlet weak private var imageView: DMImageView!
    @IBOutlet weak private var loadingView: UIActivityIndicatorView!
    @IBOutlet weak private var closeButton: UIBarButtonItem!
    
    private var isFinishedAd: Bool = false
    private let player = DMPlayer()
    private var ad: DM.RewardedAd!
    
    override var shouldAutorotate: Bool {
        return self.ad.uiDataSource?.rewardedAd?(shouldAutorotate: self.ad) ?? super.shouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.ad.uiDataSource?.rewardedAd?(supportedInterfaceOrientations: self.ad) ?? super.supportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.ad.uiDataSource?.rewardedAd?(preferredInterfaceOrientationForPresentation: self.ad) ?? super.preferredInterfaceOrientationForPresentation
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        try? DmAudioSession.setActive()
        self.playerView.player = self.player.player
        self.player.delegate = self
        self.drawAd()
        self.addSubscribers()
    }
    
    private func addSubscribers() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func willEnterForeground() {
        guard !self.isFinishedAd else {
            return
        }
        self.player.play()
    }
    
    //MARK: - private
    
    private func drawAd() {
        let url = self.ad.video.url
        self.player.replace(url: url)
        self.player.play()
        self.imageView.setImage(url: self.ad.image?.url)
    }
    
    private func sendImpression() {
        self.ad.sendImpression { [weak self] result in
            switch result {
            case .success(_):
                self?.closeButton.isEnabled = true
            case .failure(_):
                self?.closeButton.isEnabled = true
            }
        }
    }
    
    @IBAction private func didSelectCloseButton(_ sender: Any) {
        self.ad.addDidCompleted(error: nil)
        self.dismiss(animated: true)
    }
    
    @IBAction private func didSelectView(_ sender: Any) {
        self.ad.adClick { _ in }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension DMRewardedAdViewController: DMPlayerDelegate {
    
    func player(didChangeTime player: DMPlayer, time: TimeInterval) {}
    
    func player(didChangeStatus player: DMPlayer, status: DMPlayer.Status) {}
    
    func player(didChangeLoading player: DMPlayer, isLoading: Bool) {
        if isLoading {
            self.loadingView.startAnimating()
        } else {
            self.loadingView.stopAnimating()
        }
    }
    
    func player(didChangeReadyToPlay player: DMPlayer, isReadyToPlay: Bool) {
        self.ad.didStartPlaying()
    }
    
    func player(didFinishPlaying player: DMPlayer) {
        self.sendImpression()
        self.playerView.isHidden = true
        self.imageView.isHidden = false
        self.isFinishedAd = true
    }

    func player(didReceiveError player: DMPlayer, error: IDMError) {
        self.ad.addDidCompleted(error: error)
        self.dismiss(animated: true)
    }
    
}

extension DMRewardedAdViewController {
    
    class func create(ad: DM.RewardedAd) -> UIViewController {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: DM.bundle)
        let navVC = storyboard.instantiateViewController(withIdentifier: "RewardedAdViewControllerID") as! UINavigationController
        let result = navVC.viewControllers.first as! DMRewardedAdViewController
        result.ad = ad
        return navVC
    }
    
}
