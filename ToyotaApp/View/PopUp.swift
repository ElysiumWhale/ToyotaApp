import Foundation
import SwiftEntryKit
import UIKit

class PopUp {
    private init() { }

    private static let mainRedColor: EKColor = .init(red: 171, green: 97, blue: 99)
    private static let font: UIFont = .toyotaType(.semibold, of: 20)

    class func displayChoice(with title: String, description: String, confirmText: String, declineText: String, confirmCompletion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let labelStyle = EKProperty.LabelStyle(font: font, color: .white, alignment: .center)
            let titleLabel = EKProperty.LabelContent(text: title, style: labelStyle)
            let descrLabel = EKProperty.LabelContent(text: description, style: labelStyle)
            let message = EKAlertMessage(simpleMessage: .init(title: titleLabel, description: descrLabel),
                                         buttonBarContent: createButtons(confirmText, declineText,
                                                                         confirmCompletion))
            let view = EKAlertMessageView(with: message)
            SwiftEntryKit.display(entry: view, using: attributesPreset)
        }
    }

    class func displayMessage(with title: String, description: String, buttonText: String = .common(.ok), dismissCompletion: @escaping () -> Void = { }) {
        DispatchQueue.main.async {
            let view = EKPopUpMessageView(with: popUpMessagePreset(title: title, description: description,
                                                                   buttonText: buttonText, dismissCompletion))
            SwiftEntryKit.display(entry: view, using: attributesPreset)
        }
    }

    class private func popUpMessagePreset(title: String, description: String, buttonText: String, _ dismissCompletion: @escaping () -> Void = { }) -> EKPopUpMessage {
        let labelStyle = EKProperty.LabelStyle(font: font, color: .white, alignment: .center)
        let titleLabel = EKProperty.LabelContent(text: title, style: labelStyle)
        let descrLabel = EKProperty.LabelContent(text: description, style: labelStyle)
        let buttonContent = EKProperty.LabelContent(text: buttonText, style: .init(font: font, color: mainRedColor))
        let button = EKProperty.ButtonContent(label: buttonContent,
                                              backgroundColor: .white,
                                              highlightedBackgroundColor: .clear)
        
        return EKPopUpMessage(title: titleLabel, description: descrLabel, button: button) {
            dismissCompletion()
            SwiftEntryKit.dismiss()
        }
    }

    private static var attributesPreset: EKAttributes = {
        var attr = EKAttributes.centerFloat
        attr.displayDuration = .infinity
        attr.entryBackground = .color(color: mainRedColor)
        attr.screenBackground = .visualEffect(style: .init(style: .prominent))
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attr.entranceAnimation = .init(translate: .init(duration: 0.5, spring: .init(damping: 1, initialVelocity: 0)))
        attr.exitAnimation = .init(translate: .init(duration: 0.2))
        attr.popBehavior = .animated(animation: .init(translate: .init(duration: 0.1)))
        attr.positionConstraints.verticalOffset = 50
        attr.statusBar = .dark
        return attr
    }()

    class private func createButtons(_ confirmText: String, _ declineText: String, _ confirmCompletion: @escaping () -> Void) -> EKProperty.ButtonBarContent {
        let buttonFont = EKProperty.LabelStyle(font: font, color: .white)
        let buttonContent = EKProperty.LabelContent(text: confirmText, style: buttonFont)
        let confirmButton = EKProperty.ButtonContent(label: buttonContent,
                                                     backgroundColor: mainRedColor,
                                                     highlightedBackgroundColor: .clear,
                                                     action: confirmCompletion)
        let labelContent = EKProperty.LabelContent(text: declineText, style: buttonFont)
        let declineButton = EKProperty.ButtonContent(label: labelContent,
                                                     backgroundColor: mainRedColor,
                                                     highlightedBackgroundColor: .clear,
                                                     action: { SwiftEntryKit.dismiss() })
        
        return EKProperty.ButtonBarContent(with: confirmButton, declineButton, separatorColor: .clear, expandAnimatedly: true)
    }
}

extension PopUp {
    enum MessageTypes {
        case error(description: String)
        case warning(description: String)
        case success(description: String)
    }
    
    static func display(_ type: MessageTypes, completion: @escaping () -> Void = { }) {
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
        }
    }
}
