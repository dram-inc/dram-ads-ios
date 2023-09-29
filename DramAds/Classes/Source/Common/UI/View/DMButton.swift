//
//  DMButton.swift
//  DramAds
//
//  Created by Khoren Asatryan on 27.09.23.
//

import UIKit

class DMButton: UIButton {
    
    private var currentAlpha: CGFloat = 1
    
    @IBInspectable var cornerTopLeft: Bool = true {
        didSet {
            self.setRadius()
        }
    }
    
    @IBInspectable var cornerTopRight: Bool = true {
        didSet {
            self.setRadius()
        }
    }
    
    @IBInspectable var cornerBottomLeft: Bool = true {
        didSet {
            self.setRadius()
        }
    }
    
    @IBInspectable var cornerBottomRight: Bool = true {
        didSet {
            self.setRadius()
        }
    }

    @IBInspectable var circle: Bool = false {
        didSet {
            self.setRadius()
        }
    }

    @IBInspectable var radius: CGFloat = 1 {
        didSet {
            self.setRadius()
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.setRadius()
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = self.borderWidth

        }
    }

    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }

    @IBInspectable var shadowOffset: CGSize = CGSize(width: 0, height: 0) {
        didSet {
            self.layer.shadowOffset = shadowOffset
        }
    }

    @IBInspectable var shadowOpacity: Float = 1.0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }

    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.black {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    override var alpha: CGFloat {
        set {
            self.currentAlpha = newValue
            super.alpha = self.culculateAlpha()
        } get {
            return self.currentAlpha
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            super.alpha = self.culculateAlpha()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            super.alpha = self.culculateAlpha()
        }
    }
    
    private var isUpdatingVarebles: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setRadius()
    }
    
    // MARK: - Private methods
    
    private func setRadius()  {
        guard self.isUpdatingVarebles == false else { return }
        var radius:CGFloat = 0
        if self.circle {
            radius = fmin(self.frame.size.height, self.frame.size.width);
            radius = radius/2
        }else if self.radius < 1 {
            radius = fmin(self.frame.size.height, self.frame.size.width);
            radius = radius * self.radius
        }else {
            radius = self.cornerRadius
        }
        self.roundCorners(radius: radius)
    }
    
    private func roundCorners(radius: CGFloat) {
        var corners: CACornerMask = []
        if self.cornerTopLeft {
            corners.update(with: CACornerMask.layerMinXMinYCorner)
        }
        if self.cornerTopRight {
            corners.update(with: CACornerMask.layerMaxXMinYCorner)
        }
        if self.cornerBottomLeft {
            corners.update(with: CACornerMask.layerMinXMaxYCorner)
        }
        if self.cornerBottomRight {
            corners.update(with: CACornerMask.layerMaxXMaxYCorner)
        }
        self.layer.maskedCorners = corners
        self.layer.cornerRadius = radius
    }
    
    private func culculateAlpha() -> CGFloat {
        var alpha = self.currentAlpha
        if !self.isEnabled {
            alpha = alpha - 0.3
        }
        if self.isHighlighted {
            alpha = alpha - 0.3
        }
        alpha = max(.zero, alpha)
        return alpha
    }

    
}
