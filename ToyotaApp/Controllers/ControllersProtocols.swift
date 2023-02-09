import UIKit

// MARK: - Outputable
protocol Outputable<TOutput>: AnyObject {
    associatedtype TOutput

    var output: ParameterClosure<TOutput>? { get set }
}

// MARK: - Inputable
protocol Inputable<TInput>: AnyObject {
    associatedtype TInput

    func input(_ value: TInput)
}

extension Outputable {
    @discardableResult
    func withOutput(_ output: ParameterClosure<TOutput>?) -> Self {
        self.output = output
        return self
    }
}

// MARK: - Keyboard auto insets
protocol Keyboardable: UIViewController {
    associatedtype ScrollableView: UIScrollView

    var scrollView: ScrollableView! { get }

    func setupKeyboard(isSubscribing: Bool)
}

extension Keyboardable {
    func setupKeyboard(isSubscribing: Bool) {
        guard isSubscribing else {
            NotificationCenter.default.removeObserver(self)
            return
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil, queue: .main
        ) { [weak self] notification in
            self?.keyboardWillShow(notification: notification)
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.keyboardWillHide()
        }
    }

    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
                  return
              }

        // Workaround of the situation when height is less than 300 inset does not change
        let heightInset = keyboardSize.cgRectValue.height < 300 ? 300 : keyboardSize.cgRectValue.height
        let contentInsets = UIEdgeInsets(
            top: 0.0, left: 0.0,
            bottom: heightInset, right: 0.0
        )

        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
      }

    private func keyboardWillHide() {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
}
