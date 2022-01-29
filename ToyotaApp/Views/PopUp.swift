import SwiftEntryKit
import UIKit

typealias LabelContent = EKProperty.LabelContent
typealias ButtonContent = EKProperty.ButtonContent
typealias ButtonBarContent = EKProperty.ButtonBarContent

class PopUp {
    private init() { }

    // MARK: - Constants

    private static let popupColor: EKColor = .init(light: .appTint(.background),
                                                   dark: .darkGray)
    private static let redColor = EKColor(.appTint(.secondarySignatureRed))
    private static let fontColor = EKColor(light: .appTint(.signatureGray), dark: .white)

    private static let titleLabelStyle = EKProperty.LabelStyle(font: .toyotaType(.semibold, of: 19),
                                                               color: fontColor,
                                                               alignment: .center)

    private static let messageLabelStyle = EKProperty.LabelStyle(font: .toyotaType(.book, of: 17),
                                                                 color: fontColor,
                                                                 alignment: .center)

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
        attr.entranceAnimation = .init(translate: .init(duration: 0.5,
                                                        spring: .init(damping: 1, initialVelocity: 0)))
        attr.exitAnimation = .init(translate: .init(duration: 0.2))
        attr.popBehavior = .animated(animation: .init(translate: .init(duration: 0.1)))
        attr.positionConstraints.verticalOffset = 50
        attr.statusBar = .inferred
        return attr
    }()

    // MARK: - Display methods

    class private func display(alert: EKAlertMessage) {
        let view = EKAlertMessageView(with: alert)
        view.layer.cornerRadius = 8
        SwiftEntryKit.display(entry: view, using: configuration)
    }

    class func displayChoice(with title: String,
                             description: String,
                             confirmText: String,
                             declineText: String,
                             confirmCompletion: @escaping Closure) {

        DispatchQueue.main.async {
            let message = buildAlertWithChoiceMessage(with: title,
                                                      description: description,
                                                      confirmText: confirmText,
                                                      declineText: declineText,
                                                      confirmCompletion: confirmCompletion)
            display(alert: message)
        }
    }

    class func displayMessage(with title: String,
                              description: String,
                              buttonText: String = .common(.ok),
                              dismissCompletion: @escaping Closure = { }) {

        DispatchQueue.main.async {
            let message = buildAlertMessage(title: title,
                                            description: description,
                                            buttonText: buttonText,
                                            dismissCompletion)

            display(alert: message)
        }
    }

    // MARK: - AlertMessage building

    class private func buildAlertWithChoiceMessage(with title: String,
                                                   description: String,
                                                   confirmText: String,
                                                   declineText: String,
                                                   confirmCompletion: @escaping Closure) -> EKAlertMessage {
        let titleLabel = LabelContent(text: title, style: titleLabelStyle)
        let descrLabel = LabelContent(text: description, style: messageLabelStyle)
        let buttonBar = buildChoiceButtons(confirmText, declineText, confirmCompletion)

        return EKAlertMessage(simpleMessage: .init(title: titleLabel, description: descrLabel),
                              buttonBarContent: buttonBar)
    }

    class private func buildAlertMessage(title: String,
                                         description: String,
                                         buttonText: String,
                                         _ dismissCompletion: @escaping Closure = { }) -> EKAlertMessage {

        let titleLabel = LabelContent(text: title, style: titleLabelStyle)
        let descrLabel = LabelContent(text: description, style: messageLabelStyle)

        let buttonBar = buildSingleButton(text: buttonText, dismissCompletion)

        return EKAlertMessage(simpleMessage: .init(title: titleLabel, description: descrLabel),
                              buttonBarContent: buttonBar)
    }

    // MARK: - Buttons building

    class private func buildSingleButton(text: String,
                                         _ dismissCompletion: @escaping Closure = { }) -> ButtonBarContent {
        let buttonLabel = LabelContent(text: text, style: titleLabelStyle)

        let button = ButtonContent(label: buttonLabel,
                                   backgroundColor: .clear,
                                   highlightedBackgroundColor: redColor) {
            dismissCompletion()
            SwiftEntryKit.dismiss()
        }

        return ButtonBarContent(with: button,
                                separatorColor: .clear,
                                expandAnimatedly: false)
    }

    class private func buildChoiceButtons(_ confirmText: String,
                                          _ declineText: String,
                                          _ confirmCompletion: @escaping Closure) -> ButtonBarContent {

        let buttonContent = LabelContent(text: confirmText, style: titleLabelStyle)
        let confirmButton = ButtonContent(label: buttonContent,
                                          backgroundColor: .clear,
                                          highlightedBackgroundColor: redColor) {
            confirmCompletion()
            SwiftEntryKit.dismiss()
        }

        let labelContent = LabelContent(text: declineText, style: titleLabelStyle)
        let declineButton = ButtonContent(label: labelContent,
                                          backgroundColor: .clear,
                                          highlightedBackgroundColor: redColor) {
            SwiftEntryKit.dismiss()
        }

        return ButtonBarContent(with: confirmButton, declineButton,
                                separatorColor: EKColor(.opaqueSeparator),
                                expandAnimatedly: false)
    }
}

// MARK: - Helper methods
extension PopUp {
    enum MessageTypes {
        case error(description: String)
        case warning(description: String)
        case success(description: String)
        case choise(description: String)
    }

    static func display(_ type: MessageTypes, completion: @escaping Closure = { }) {
        switch type {
            case .error(let text):
                displayMessage(with: .common(.error),
                               description: text,
                               dismissCompletion: completion)
            case .warning(let text):
                displayMessage(with: .common(.warning),
                               description: text,
                               dismissCompletion: completion)
            case .success(let text):
                displayMessage(with: .common(.success),
                               description: text,
                               dismissCompletion: completion)
            case .choise(let text):
                displayChoice(with: .common(.actionConfirmation),
                              description: text,
                              confirmText: .common(.yes),
                              declineText: .common(.cancel),
                              confirmCompletion: completion)
        }
    }
}
