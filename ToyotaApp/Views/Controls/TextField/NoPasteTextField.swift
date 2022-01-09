import UIKit

class NoPasteTextField: InputTextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.cut(_:)) {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}

class NoCopyPasteTexField: InputTextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool { false }

    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] { [] }

    override func caretRect(for position: UITextPosition) -> CGRect { .zero }

    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.numberOfTouches == 1 {
            return true
        }
        return false
    }
}
