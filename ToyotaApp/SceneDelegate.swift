import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {

        guard !isTesting else {
            return
        }

        guard let windowScene = scene as? UIWindowScene else {
            return
        }

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UtilsFlow.splashScreenModule()
        window?.makeKeyAndVisible()

        NavigationService.switchRootView = changeRootViewController

        guard
            let userId: UserId = KeychainService.shared.get(),
            let secretKey: SecretKey = KeychainService.shared.get()
        else {
            NavigationService.loadAuth()
            return
        }

        checkUserAuthorization(userId.value, secretKey.value, Brand.Toyota)
    }

    private func checkUserAuthorization(
        _ userId: String,
        _ secret: String,
        _ brandId: String
    ) {
        let body = CheckUserBody(
            userId: userId,
            secret: secret,
            brandId: Brand.Toyota
        )

        Task {
            switch await NewInfoService().checkUser(body) {
            case let .success(data):
                handle(success: data)
            case let .failure(error):
                handle(error: error)
            }
        }
    }

    private func handle(success response: CheckUserOrSmsCodeResponse) {
        KeychainService.shared.set(SecretKey(value: response.secretKey))
        NavigationService.resolveNavigation(
            context: CheckUserContext(response: response)
        ) {
            NavigationService.loadAuth()
        }
    }

    private func handle(error response: ErrorResponse) {
        switch response.errorCode {
        case .lostConnection:
            NavigationService.loadConnectionLost()
        default:
            KeychainService.shared.remove(SecretKey.self)
            NavigationService.loadAuth(
                with: response.message ?? .error(.errorWhileAuth)
            )
        }
    }
}

// MARK: - isTesting
private extension SceneDelegate {
    var isTesting: Bool {
        ProcessInfo.processInfo.arguments.contains("isTesting")
    }
}

// MARK: - Navigation
private extension SceneDelegate {
    func changeRootViewController(_ vc: UIViewController) {
        guard let window = window else {
            return
        }

        window.rootViewController = vc

        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionFlipFromLeft],
            animations: nil
        )
    }
}

// MARK: - SceneDid... EventHandlers
extension SceneDelegate {
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
