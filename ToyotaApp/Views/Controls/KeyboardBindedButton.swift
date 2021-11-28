import UIKit

class KeyboardBindedButton: CustomizableButton {
    @IBOutlet var keyboardConstraint: NSLayoutConstraint?
    
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let endFrameHeight = endFrame?.size.height ?? 0
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let animationCurve = UIView.AnimationOptions(rawValue: curve)
        let mainHeight = UIScreen.main.bounds.size.height
        
        UIView.animate(withDuration: duration, delay: 0.0,
                       options: animationCurve,
                       animations: { [self] in
                            keyboardConstraint?.constant = endFrameY >= mainHeight ? 0.0 : endFrameHeight - 20
                            superview?.layoutIfNeeded()
                       })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
