import UIKit
import HelpCrunchSDK

enum ChatFlow {
    static func startChat(from controller: UIViewController) {
        let theme: HCSTheme
        switch controller.interfaceStyle {
            case .dark:
                theme = HelpCrunch.darkTheme()
            default:
                theme = HelpCrunch.lightTheme()
        }

        theme.mainColor = .appTint(.secondarySignatureRed)
        theme.sendMessageArea.sendButtonText = .empty
        theme.sendMessageArea.sendButtonIconImage = .sendMessageImage
        HelpCrunch.bindTheme(theme)
        HelpCrunch.show(from: controller)
    }
}

extension UIImage {
    static var sendMessageImage: UIImage {
        UIImage(systemName: "arrow.forward.circle.fill")?
            .withTintColor(.appTint(.secondarySignatureRed)) ?? UIImage()
    }
}
