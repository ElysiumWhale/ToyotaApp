import SwiftEntryKit
import UIKit

typealias LabelContent = EKProperty.LabelContent
typealias ButtonContent = EKProperty.ButtonContent
typealias ButtonBarContent = EKProperty.ButtonBarContent

enum PopUp {

    // MARK: - Constants
    private static let popupColor: EKColor = .init(light: .appTint(.background),
                                                   dark: .darkGray)
    private static let redColor = EKColor(.appTint(.secondarySignatureRed))
    private static let fontColor = EKColor(light: .appTint(.signatureGray),
                                           dark: .white)

    private static let titleLabelStyle = EKProperty.LabelStyle(
        font: .toyotaType(.semibold, of: 19),
        color: fontColor,
        alignment: .center
    )

    private static let messageLabelStyle = EKProperty.LabelStyle(
        font: .toyotaType(.book, of: 17),
        color: fontColor,
        alignment: .center
    )

    private static let configuration: EKAttributes = {
        var attr = EKAttributes.centerFloat
        attr.displayDuration = .infinity
        attr.entryBackground = .color(color: popupColor)
        attr.screenBackground = .visualEffect(style: .standard)
        attr.hapticFeedbackType = .warning
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 5))
        attr.screenInteraction = .absorbTouches
        attr.entryInteraction = .absorbTouches
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attr.entranceAnimation = .init(translate: .init(
            duration: 0.5,
            spring: .init(damping: 1, initialVelocity: 0)
        ))
        attr.exitAnimation = .init(translate: .init(duration: 0.2))
        attr.popBehavior = .animated(animation: .init(
            translate: .init(duration: 0.1)
        ))
        attr.positionConstraints.verticalOffset = 50
        attr.statusBar = .inferred
        return attr
    }()

    // MARK: - Display methods
    static private func display(alert: EKAlertMessage) {
        let view = EKAlertMessageView(with: alert)
        view.layer.cornerRadius = 8
        SwiftEntryKit.display(entry: view, using: configuration)
    }

    static func displayChoice(
        with title: String,
        description: String,
        confirmText: String = .common(.yes),
        declineText: String = .common(.cancel),
        onConfirm: @escaping Closure
    ) {

        DispatchQueue.main.async {
            let message = buildAlertWithChoiceMessage(
                with: title,
                description: description,
                confirmText: confirmText,
                declineText: declineText,
                onConfirm: onConfirm
            )
            display(alert: message)
        }
    }

    static func displayMessage(
        with title: String,
        description: String,
        buttonText: String = .common(.ok),
        onDismiss: @escaping Closure = { }
    ) {

        DispatchQueue.main.async {
            let message = buildAlertMessage(
                title: title,
                description: description,
                buttonText: buttonText,
                onDismiss
            )

            display(alert: message)
        }
    }

    // MARK: - AlertMessage building
    static private func buildAlertWithChoiceMessage(
        with title: String,
        description: String,
        confirmText: String,
        declineText: String,
        onConfirm: @escaping Closure
    ) -> EKAlertMessage {

        let titleLabel = LabelContent(text: title,
                                      style: titleLabelStyle)
        let descrLabel = LabelContent(text: description,
                                      style: messageLabelStyle)
        let buttonBar = buildChoiceButtons(confirmText, declineText, onConfirm)

        return EKAlertMessage(
            simpleMessage: .init(title: titleLabel,
                                 description: descrLabel),
            buttonBarContent: buttonBar
        )
    }

    static private func buildAlertMessage(
        title: String,
        description: String,
        buttonText: String,
        _ onDismiss: @escaping Closure = { }
    ) -> EKAlertMessage {

        let titleLabel = LabelContent(text: title,
                                      style: titleLabelStyle)
        let descrLabel = LabelContent(text: description,
                                      style: messageLabelStyle)

        let buttonBar = buildSingleButton(text: buttonText, onDismiss)

        return EKAlertMessage(
            simpleMessage: .init(title: titleLabel,
                                 description: descrLabel),
            buttonBarContent: buttonBar
        )
    }

    // MARK: - Buttons building
    static private func buildSingleButton(
        text: String,
        _ onDismiss: @escaping Closure = { }
    ) -> ButtonBarContent {
        let buttonLabel = LabelContent(text: text,
                                       style: titleLabelStyle)

        let button = ButtonContent(
            label: buttonLabel,
            backgroundColor: .clear,
            highlightedBackgroundColor: redColor
        ) {
            onDismiss()
            SwiftEntryKit.dismiss()
        }

        return ButtonBarContent(
            with: button,
            separatorColor: .clear,
            expandAnimatedly: false
        )
    }

    static private func buildChoiceButtons(
        _ confirmText: String,
        _ declineText: String,
        _ onConfirm: @escaping Closure
    ) -> ButtonBarContent {

        let buttonContent = LabelContent(text: confirmText,
                                         style: titleLabelStyle)
        let confirmButton = ButtonContent(
            label: buttonContent,
            backgroundColor: .clear,
            highlightedBackgroundColor: redColor
        ) {
            onConfirm()
            SwiftEntryKit.dismiss()
        }

        let labelContent = LabelContent(text: declineText,
                                        style: titleLabelStyle)
        let declineButton = ButtonContent(
            label: labelContent,
            backgroundColor: .clear,
            highlightedBackgroundColor: redColor
        ) {
            SwiftEntryKit.dismiss()
        }

        return ButtonBarContent(
            with: confirmButton,
            declineButton,
            separatorColor: EKColor(.opaqueSeparator),
            expandAnimatedly: false
        )
    }
}

// MARK: - Helper methods
extension PopUp {
    enum MessageTypes {
        case error(description: String)
        case warning(description: String)
        case success(description: String)
        case choice(description: String)
    }

    static func display(_ type: MessageTypes,
                        completion: @escaping Closure = { }) {
        switch type {
            case .error(let text):
                displayMessage(with: .common(.error),
                               description: text,
                               onDismiss: completion)
            case .warning(let text):
                displayMessage(with: .common(.warning),
                               description: text,
                               onDismiss: completion)
            case .success(let text):
                displayMessage(with: .common(.success),
                               description: text,
                               onDismiss: completion)
        case let .choice(text):
            displayChoice(
                with: .common(.actionConfirmation),
                description: text,
                confirmText: .common(.yes),
                declineText: .common(.cancel),
                onConfirm: completion
            )
        }
    }
}
