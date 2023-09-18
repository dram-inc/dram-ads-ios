//
//  DMPlayerView.swift
//  DramAdsIosSdk
//
//  Created by Khoren Asatryan on 09.09.23.
//

import UIKit
import AVKit

protocol DMPlayerViewDelegate: AnyObject {
    func playerView(didChangeReadyForDisplay playerView: DMPlayerView, isReadyForDisplay: Bool)
}

class DMPlayerView: UIView {
    
    weak var delegate: DMPlayerViewDelegate?
    
    override public class var layerClass: Swift.AnyClass {
        return AVPlayerLayer.self
    }
    
    override var backgroundColor: UIColor? {
        set {
            self.layer.backgroundColor = newValue?.cgColor
        } get {
            guard let cgColor = self.layer.backgroundColor else {
                return nil
            }
            return UIColor(cgColor: cgColor)
        }
    }
    
    var player: AVPlayer? {
        set {
            self.playerLayer.player = newValue
        } get {
            return self.playerLayer.player
        }
    }
    
    var videoRect: CGRect {
        return self.playerLayer.videoRect
    }

    var videoSize: CGSize {
        return self.player?.currentItem?.asset.videoSize() ?? self.player?.currentItem?.presentationSize ?? .zero
    }
    
    var ratioAspect: CGFloat {
        let size = self.videoSize
        return size.height == .zero ? 0 : size.width / size.height
    }
    
    var isReadyForDisplay: Bool {
        return self.playerLayer.isReadyForDisplay
    }
    
    var playerLayer: AVPlayerLayer {
        get {
            return (self.layer as! AVPlayerLayer)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == #keyPath(AVPlayerLayer.isReadyForDisplay) else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        DispatchQueue.main.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            weakSelf.delegate?.playerView(didChangeReadyForDisplay: weakSelf, isReadyForDisplay: weakSelf.isReadyForDisplay)
        }
    }
    
    //MARK: - Private func
    
    private func setup() {
        super.layer.backgroundColor = UIColor.clear.cgColor
        self.playerLayer.addObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), context: nil)
    }
    
    deinit {
        self.playerLayer.removeObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay))
    }
    
}

fileprivate extension AVAsset {
    
    func videoSize() -> CGSize? {
        guard let track = self.tracks(withMediaType: AVMediaType.video).first else {
            return nil
        }
        let size = track.naturalSize
        let txf = track.preferredTransform
        let realVidSize = size.applying(txf)
        return realVidSize
    }

}
