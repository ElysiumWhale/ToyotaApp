import Foundation
import UIKit

extension UIView {
    func fadeIn(_ duration: TimeInterval? = 0.05, onCompletion: (() -> Void)? = nil) {
        alpha = 0
        isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 1 },
                       completion: { (value: Bool) in
                          if let complete = onCompletion { complete() }
                       }
        )
    }

    func fadeOut(_ duration: TimeInterval? = 0.05, onCompletion: (() -> Void)? = nil) {
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
                           self.isHidden = true
                           if let complete = onCompletion { complete() }
                       }
        )
    }
}

extension UICollectionViewCell {
    func configureShadow(with cornerRadius: CGFloat) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        layer.shadowRadius = 3.5
        layer.shadowOpacity = 0.7
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
}

extension UIButton {
    @IBInspectable var rounded: Bool {
        get {
            layer.cornerRadius == 0 ? true : false
        }
        set {
            updateCornerRadius(isRounded: newValue)
        }
    }
    
    func updateCornerRadius(isRounded: Bool) {
        layer.cornerRadius = isRounded ? frame.size.height / 2 : 0
    }
}
