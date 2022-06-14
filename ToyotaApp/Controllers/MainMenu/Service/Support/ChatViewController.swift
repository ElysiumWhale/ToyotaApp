import UIKit

final class ChatViewController: InitialazableViewController {
    private let stabLabel = UILabel()
    private let messageField = InputTextField()
    private let sendButton = CustomizableButton(type: .custom)

    override func addViews() {
        addSubviews(stabLabel, messageField, sendButton)
    }

    override func configureLayout() {
        stabLabel.centerInSuperview()
        messageField.leftToSuperview(offset: 16)
        messageField.bottomToSuperview(offset: -20, usingSafeArea: true)
        messageField.height(45)
        messageField.rightToLeft(of: sendButton, offset: -5)
        sendButton.rightToSuperview(offset: -16)
        sendButton.centerY(to: messageField)
        sendButton.size(CGSize(width: 40, height: 40))
    }

    override func configureAppearance() {
        view.backgroundColor = .systemBackground
        stabLabel.font = .toyotaType(.semibold, of: 22)
        stabLabel.textColor = .appTint(.signatureGray)
        messageField.backgroundColor = .appTint(.background)
        messageField.cornerRadius = 10
        messageField.tintColor = .appTint(.secondarySignatureRed)
        sendButton.contentVerticalAlignment = .fill
        sendButton.contentHorizontalAlignment = .fill
        sendButton.setImage(.send, for: .normal)
        sendButton.tintColor = .appTint(.secondarySignatureRed)
    }

    override func localize() {
        messageField.placeholder = .common(.enterMessage)
        stabLabel.text = .common(.thereWillBeMessages)
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
