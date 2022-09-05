import UIKit

protocol BottomKeyboardBinded: UIView {
    var keyboardConstraint: NSLayoutConstraint? { get set }
    var constant: CGFloat { get }
}

extension BottomKeyboardBinded {
    func bindToKeyboard() {
        NotificationCenter
            .default
            .addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                         object: nil,
                         queue: .main,
                         using: keyboardWillChange)
    }

    func keyboardWillChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }

        let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let endFrameY = endFrame?.origin.y ?? 0
        let endFrameHeight = endFrame?.size.height ?? 0
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0
        let animationCurve = UIView.AnimationOptions(rawValue: curve)
        let mainHeight = UIScreen.main.bounds.size.height

        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       options: animationCurve,
                       animations: { [self] in
            keyboardConstraint?.constant = -(endFrameY >= mainHeight ? -constant : endFrameHeight + 10)
            superview?.layoutIfNeeded()
        })
    }
}
