import UIKit
import DesignKit

final class ChatViewController: BaseViewController {
    private let stabLabel = UILabel()
    private let messageField = InputTextField(.toyotaLeft)
    private let sendButton = CustomizableButton(type: .custom)

    override func addViews() {
        addSubviews(stabLabel, messageField)
    }

    override func configureLayout() {
        view.hideKeyboardWhenSwipedDown()
        stabLabel.topToSuperview(offset: 150)
        stabLabel.horizontalToSuperview(insets: .horizontal(16))
        messageField.horizontalToSuperview(insets: .horizontal(16))
        messageField.keyboardConstraint = messageField.bottomToSuperview(
            offset: -30
        )
        messageField.bindToKeyboard()
        messageField.height(45)
        messageField.setRightView(sendButton, .init(side: 40))
        sendButton.contentVerticalAlignment = .fill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.imageView?.contentMode = .scaleAspectFit
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        stabLabel.backgroundColor = view.backgroundColor
        stabLabel.font = .toyotaType(.semibold, of: 22)
        stabLabel.textColor = .appTint(.signatureGray)
        stabLabel.numberOfLines = .zero
        messageField.rightViewMode = .always
        messageField.leftPadding = 15
        sendButton.setImage(.send, for: .normal)
        sendButton.tintColor = .appTint(.secondarySignatureRed)
    }

    override func localize() {
        messageField.placeholder = .common(.enterMessage)
        stabLabel.text = .common(.thereWillBeMessages)
        navigationItem.title = .common(.support)
    }

    override func configureActions() {
        view.hideKeyboard(when: .swipe)
        sendButton.addTarget(
            self,
            action: #selector(sendButtonDidPress),
            for: .touchUpInside
        )
    }

    @objc private func sendButtonDidPress() {
        if let text = messageField.text, !text.isEmpty {
            stabLabel.text = text
            messageField.text = .empty
        }
    }
}
