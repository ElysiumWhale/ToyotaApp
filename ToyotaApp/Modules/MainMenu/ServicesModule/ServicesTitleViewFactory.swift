import UIKit

enum ServicesTitleViewFactory {
    static func make(
        _ title: String,
        _ backgroundColor: UIColor,
        _ action: @escaping () -> Void
    ) -> UIView {
        let titleButton = titleButton(
            title: title,
            backgroundColor: backgroundColor,
            action: action
        )

        let rightButton = UIButton()
        rightButton.setImage(.chevronRight, for: .normal)
        rightButton.tintColor = .appTint(.secondarySignatureRed)
        rightButton.imageView?.backgroundColor = backgroundColor
        rightButton.addAction(action)

        let container = UIView()
        container.addSubviews(titleButton, rightButton)

        titleButton.edgesToSuperview(excluding: .trailing)
        rightButton.trailingToSuperview()
        titleButton.trailingToLeading(of: rightButton)
        rightButton.centerYToSuperview(offset: 3)

        return container
    }

    static func titleButton(
        title: String,
        backgroundColor: UIColor,
        action: @escaping () -> Void
    ) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = backgroundColor
        button.setTitleColor(.appTint(.signatureGray), for: .normal)
        button.setTitleColor(
            .appTint(.secondarySignatureRed),
            for: .highlighted
        )
        button.titleLabel?.font = .toyotaType(.regular, of: 17)
        button.titleLabel?.backgroundColor = backgroundColor
        button.setTitle(title, for: .normal)
        button.addAction(action)
        return button
    }
}
