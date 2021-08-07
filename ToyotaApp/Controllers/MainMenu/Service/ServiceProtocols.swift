import UIKit

/// States which represent current activity of module
enum ModuleStates {
    /// Default state before start
    case idle
    /// Occurs when user successfully interacted with module view
    case didChose(_ service: IService)
    /// Occures when module prepared for user interacting (downloaded data etc)
    case didDownload
    /// Occures when something goes wrong: processing user input or preparing for it
    case error(_ error: ErrorResponse)
    
    /// Returns chosen service if state is `.didChose` or `nil` in rest cases
    func getService() -> IService? {
        switch self {
            case .idle, .didDownload, .error:
                return nil
            case .didChose(let service):
                return service
        }
    }
}

/// Unit for particular control logic realization.
/// Used by `IServiceController` for auto building logic and UI with help of `ServiceModuleBuilder`
protocol IServiceModule: AnyObject {
    var view: UIView? { get }
    var serviceType: ServiceType { get }
    var state: ModuleStates { get }
    var delegate: IServiceController? { get }
    func start(with params: [URLQueryItem])
    func customStart<TResponse: IServiceResponse>(page: String, with params: [URLQueryItem], response type: TResponse.Type)
    func buildQueryItems() -> [URLQueryItem]
    func configureViewText(with labelText: String)
}

extension IServiceModule {
    func customStart<TResponse: IServiceResponse>(page: String, with params: [URLQueryItem], response type: TResponse.Type) { }
    
    func start(with params: [URLQueryItem] = []) {
        start(with: [])
    }
}

/// Controller which manages `IServiceModule`s.
/// Configured by `ServiceModuleBuilder`
protocol IServiceController: AnyObject {
    var modules: [IServiceModule] { get }
    var user: UserProxy? { get }
    func moduleDidUpdate(_ module: IServiceModule)
    func configure(with service: ServiceType, modules: [IServiceModule], user: UserProxy)
}

protocol IService: Codable {
    var id: String { get }
    var name: String { get }
}

protocol IServiceResponse: Codable {
    var result: String { get }
    var array: [IService] { get }
}
