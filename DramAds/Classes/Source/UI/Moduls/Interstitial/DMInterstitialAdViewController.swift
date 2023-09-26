//
//  DMInterstitialAdViewController.swift
//  DramAds
//
//  Created by Khoren Asatryan on 24.09.23.
//

import UIKit

class DMInterstitialAdViewController: UIViewController {
    
    @IBOutlet weak private var imageView: DMImageView!
    @IBOutlet weak private var playerView: DMPlayerView!
    @IBOutlet weak private var closeButton: UIButton!
    @IBOutlet weak private var contentView: UIView!
    
    private var ad: DM.InterstitialAD!
    private var isFinishedAd: Bool = false
    private var timeCalculator: DMPlayer.TimeCalculator?
    private var player = DMPlayer()
    private var timer: DmTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calculateRatioLayoutConstraint()
        self.addNotifications()
        self.configureView()
    }
    
    //MARK: - User action
    
    @IBAction private func didSelectCloseButton(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    //MARK: - Private func
    
    private func configureView() {
        self.closeButton.isEnabled = false
        self.imageView.setImage(url: self.ad.image?.url)
        self.imageView.isHidden = true
        if let url = self.ad.video?.url {
            self.playerView.player = self.player.player
            self.timeCalculator = DMPlayer.TimeCalculator(player: self.player) { [weak self] state, playback in
                self?.didChangeTime(playback)
            }
            self.player.replace(url: url)
            self.player.play()
            self.player.delegate = self
        } else {
            self.updateImageView()
            self.timer = DmTimer()
            self.timer?.fire(interval: 1, block: { [weak self] time in
                self?.didChangeTime(time)
            })
            self.didChangeTime(.zero)
        }
    }
    
    private func calculateRatioLayoutConstraint() {
        let width = max(self.ad.video?.width ?? .zero, self.ad.image?.width ?? .zero)
        let height = max(self.ad.video?.height ?? .zero, self.ad.image?.height ?? .zero)
        guard !(width * height).isZero else {
            return
        }
        self.contentView.widthAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: CGFloat(width / height)).isActive = true
    }
    
    private func updateImageView() {
        self.playerView.isHidden = true
        self.imageView.isHidden = false
    }
    
    private func didChangeTime(_ time: TimeInterval) {
        let timeValue =  TimeInterval(Int(time))
        let time = TimeInterval(Int(max(.zero, (self.ad.skipTime ?? .zero) - timeValue)))
        let title = time > .zero ? time.timeFormat() : nil
        self.closeButton.setTitle(title, for: .disabled)
        self.closeButton.isEnabled = time.isZero
    }
    
    private func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func willEnterForeground() {
        guard !self.isFinishedAd else {
            return
        }
        self.player.play()
    }
        
}

extension DMInterstitialAdViewController: DMPlayerDelegate {
    
    func player(didFinishPlaying player: DMPlayer) {
        self.isFinishedAd = true
        self.updateImageView()
    }
    
    func player(didReceiveError player: DMPlayer, error: IDMError) {
        self.updateImageView()
    }
}

extension DMInterstitialAdViewController {
    
    class func create(ad: DM.InterstitialAD) -> UIViewController {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: DM.bundle)
        let result = storyboard.instantiateViewController(withIdentifier: "DMInterstitialAdViewControllerID") as! DMInterstitialAdViewController
        result.ad = ad
        return result
    }
    
}
