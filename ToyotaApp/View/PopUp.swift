import Foundation
import SwiftEntryKit
import UIKit

class PopUp {
    private init() { }
    
    private static let mainRedColor: EKColor = .init(red: 171, green: 97, blue: 99)
    private static let font = UIFont.toyotaType(.semibold, of: 20)
    
    class func displayChoice(with title: String, description: String, confirmText: String, declineText: String, confirmCompletion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let titleLabel = EKProperty.LabelContent(text: title, style: EKProperty.LabelStyle(font: font, color: .white, alignment: .center))
            let descrLabel = EKProperty.LabelContent(text: description, style: EKProperty.LabelStyle(font:  font, color: .white, alignment: .center))
            SwiftEntryKit.display(entry: EKAlertMessageView(with: .init(simpleMessage: .init(title: titleLabel, description: descrLabel), buttonBarContent: createButtons(confirmText, declineText, confirmCompletion))), using: attributesPreset)
        }
    }
    
    class func displayMessage(with title: String, description: String, buttonText: String, dismissCompletion: @escaping () -> Void = { }) {
        DispatchQueue.main.async {
            SwiftEntryKit.display(entry: EKPopUpMessageView(with: popUpMessagePreset(title: title, description: description, buttonText: buttonText, dismissCompletion)), using: attributesPreset)
        }
    }
    
    class private func popUpMessagePreset(title: String, description: String, buttonText: String, _ dismissCompletion: @escaping () -> Void = { }) -> EKPopUpMessage {
        let titleLabel = EKProperty.LabelContent(text: title, style: EKProperty.LabelStyle(font: font, color: .white, alignment: .center))
        let descrLabel = EKProperty.LabelContent(text: description, style: EKProperty.LabelStyle(font: font, color: .white, alignment: .center))
        let button = EKProperty.ButtonContent(label: .init(text: buttonText, style: .init(font: font, color: mainRedColor)), backgroundColor: .white, highlightedBackgroundColor: .clear)
        
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
        //.color(color: .init(light: UIColor(white: 100.0/255.0, alpha: 0.3), dark: UIColor(white: 50.0/255.0, alpha: 0.3)))
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
        let confirmButton = EKProperty.ButtonContent.init(label: EKProperty.LabelContent.init(text: confirmText, style: buttonFont), backgroundColor: mainRedColor, highlightedBackgroundColor: .clear, action: confirmCompletion)
        let declineButton = EKProperty.ButtonContent.init(label: EKProperty.LabelContent.init(text: declineText, style: buttonFont), backgroundColor: mainRedColor, highlightedBackgroundColor: .clear, action: { SwiftEntryKit.dismiss() })
        
        return EKProperty.ButtonBarContent(with: confirmButton, declineButton, separatorColor: .clear, expandAnimatedly: true)
    }
}
