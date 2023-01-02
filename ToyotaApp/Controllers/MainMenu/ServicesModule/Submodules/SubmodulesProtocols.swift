import UIKit

enum ModuleAppearances {
    case title(_ string: String)
    case placeholder(_ string: String)
}

/// States which represent current activity of module
enum ModuleStates {
    /// Default state before start
    case idle
    /// Occurs when user successfully interacted with module view
    case didChose(_ service: IService)
    /// Occurs when module prepared for user interacting (downloaded data etc)
    case didDownload
    /// Occurs when something goes wrong: processing user input or preparing for it
    case error(_ error: ErrorResponse)

    /// Occurs when we need block some controls in module and book button
    /// - **Example:** user restricted access to location in `MapModule`
    case block(_ message: String?)

    /// Returns chosen service if state is `.didChose` or `nil` in rest cases
    var service: IService? {
        switch self {
            case .idle, .didDownload, .error, .block:
                return nil
            case let .didChose(service):
                return service
        }
    }
}

/// Unit for particular control logic realization.
/// Used by `IServiceController` for auto building logic and UI with help of `ServiceModuleBuilder`
protocol IServiceModule: AnyObject {
    var view: UIView { get }
    var state: ModuleStates { get }
    var nextModule: IServiceModule? { get set }
    var onUpdate: ((IServiceModule) -> Void)? { get set }

    func start(with params: RequestItems)
    func customStart<TResponse: IServiceResponse>(page: RequestPath,
                                                  with params: RequestItems,
                                                  response type: TResponse.Type)
    func buildQueryItems() -> RequestItems
    func configure(appearance: [ModuleAppearances])
}

extension IServiceModule {
    func customStart<TResponse: IServiceResponse>(page: RequestPath,
                                                  with params: RequestItems,
                                                  response type: TResponse.Type) { }

    func start(with params: RequestItems = []) {
        start(with: [])
    }

    func configure(appearance: [ModuleAppearances]) { }
}

protocol IService: Codable {
    var id: String { get }
    var name: String { get }
}

protocol IServiceResponse: IResponse {
    associatedtype TService: IService

    var result: String { get }
    var array: [TService] { get }
}
