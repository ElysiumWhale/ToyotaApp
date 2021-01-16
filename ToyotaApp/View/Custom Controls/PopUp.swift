import Foundation
import SwiftEntryKit
import UIKit

class PopUp {
    private init() { }
    
    class func displayChoice(with title: String, description: String, confirmText: String, declineText: String, confirmCompletion: @escaping () -> Void) {
        
        let titleLabel = EKProperty.LabelContent(text: title, style: EKProperty.LabelStyle(font: UIFont.boldSystemFont(ofSize: 20), color: EKColor(light: .white, dark: .white), alignment: .center))
        let descrLabel = EKProperty.LabelContent(text: description, style: EKProperty.LabelStyle(font: UIFont.boldSystemFont(ofSize: 20), color: EKColor(light: .white, dark: .black), alignment: .center))
        
        SwiftEntryKit.display(entry: EKAlertMessageView(with: .init(simpleMessage: .init(title: titleLabel, description: descrLabel), buttonBarContent: createButtons(confirmText, declineText, confirmCompletion))), using: attributesPreset)
    }
    
    class func displayMessage(with title: String, description: String, buttonText: String) {
        SwiftEntryKit.display(entry: EKPopUpMessageView(with: popUpMessagePreset(title: title, description: description, buttonText: buttonText)), using: attributesPreset)
    }
    
    class private func popUpMessagePreset(title: String, description: String, buttonText: String) -> EKPopUpMessage {
            let titleLabel = EKProperty.LabelContent(text: title, style: EKProperty.LabelStyle(font: UIFont.boldSystemFont(ofSize: 20), color: EKColor(light: .white, dark: .white), alignment: .center))
            let descrLabel = EKProperty.LabelContent(text: description, style: EKProperty.LabelStyle(font: UIFont.boldSystemFont(ofSize: 20), color: EKColor(light: .white, dark: .black), alignment: .center))
            let button = EKProperty.ButtonContent(label: .init(text: buttonText, style: .init(font: UIFont.boldSystemFont(ofSize: 20), color: .init(red: 223, green: 66, blue: 76))), backgroundColor: .init(UIColor.white), highlightedBackgroundColor: .clear)
            return EKPopUpMessage(title: titleLabel, description: descrLabel, button: button, action: { SwiftEntryKit.dismiss() })
    }
    
    private static var attributesPreset: EKAttributes = {
        var attr = EKAttributes.centerFloat
        //attr.entryBackground = .gradient(gradient: .init(colors: [EKColor(.white), EKColor(.red)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attr.entryBackground = .color(color: .init(red: 223, green: 66, blue: 76))
        attr.displayDuration = .infinity
        attr.screenBackground = .color(color: .init(light: UIColor(white: 100.0/255.0, alpha: 0.3), dark: UIColor(white: 50.0/255.0, alpha: 0.3)))
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attr.entranceAnimation = .init(translate: .init(duration: 0.7,  spring: .init(damping: 1, initialVelocity: 0)), scale: .init(from: 1.05, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        attr.exitAnimation = .init(translate: .init(duration: 0.2))
        attr.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        attr.positionConstraints.verticalOffset = 50
        attr.statusBar = .dark
        return attr
    }()
    
    class private func createButtons(_ confirmText: String, _ declineText: String, _ confirmCompletion: @escaping () -> Void) -> EKProperty.ButtonBarContent {
        let buttonFont = EKProperty.LabelStyle(font: UIFont(name: "ToyotaType-Semibold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20), color: .init(red: 223, green: 66, blue: 76))
        let confirmButton = EKProperty.ButtonContent.init(label: EKProperty.LabelContent.init(text: confirmText, style: buttonFont), backgroundColor: .init(UIColor.white), highlightedBackgroundColor: .clear, action: confirmCompletion)
        let declineButton = EKProperty.ButtonContent.init(label: EKProperty.LabelContent.init(text: declineText, style: buttonFont), backgroundColor: .init(UIColor.white), highlightedBackgroundColor: .clear, action: { SwiftEntryKit.dismiss() })
        
        return EKProperty.ButtonBarContent(with: confirmButton, declineButton, separatorColor: .clear, expandAnimatedly: true)
         //EKButtonBarView(with: buttonContent)
    }
    
}
