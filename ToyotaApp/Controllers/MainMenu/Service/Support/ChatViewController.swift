import UIKit

final class ChatViewController: InitialazableViewController {
    private let stabLabel = UILabel()
    private let messageField = InputTextField()
    private let sendButton = CustomizableButton(type: .custom)

    override func addViews() {
        addSubviews(stabLabel, messageField)
    }

    override func configureLayout() {
        view.hideKeyboardWhenSwipedDown()
        stabLabel.topToSuperview(offset: 150)
        stabLabel.horizontalToSuperview(insets: .horizontal(16))
        messageField.horizontalToSuperview(insets: .horizontal(16))
        messageField.keyboardConstraint = messageField.bottomToSuperview(offset: -20)
        messageField.bindToKeyboard()
        messageField.height(45)
        messageField.setRightView(from: sendButton, width: 40, height: 40)
        sendButton.contentVerticalAlignment = .fill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.imageView?.contentMode = .scaleAspectFit
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        stabLabel.font = .toyotaType(.semibold, of: 22)
        stabLabel.textColor = .appTint(.signatureGray)
        stabLabel.numberOfLines = .zero
        messageField.backgroundColor = .appTint(.background)
        messageField.cornerRadius = 10
        messageField.tintColor = .appTint(.secondarySignatureRed)
        messageField.rightViewMode = .always
        sendButton.setImage(.send, for: .normal)
        sendButton.tintColor = .appTint(.secondarySignatureRed)
    }

    override func localize() {
        messageField.placeholder = .common(.enterMessage)
        stabLabel.text = .common(.thereWillBeMessages)
        navigationItem.title = .common(.support)
    }

    override func configureActions() {
        sendButton.addTarget(self,
                             action: #selector(sendButtonDidPress),
                             for: .touchUpInside)
    }

    @objc private func sendButtonDidPress() {
        if let text = messageField.text, !text.isEmpty {
            stabLabel.text = text
            messageField.text = .empty
        }
    }
}
