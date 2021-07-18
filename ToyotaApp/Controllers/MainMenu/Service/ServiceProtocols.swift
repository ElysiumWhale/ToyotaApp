import UIKit

///Unit for particular control logic realization.
///Used by `IServiceController` for auto building logic and UI with help of `ServiceModuleBuilder`
protocol IServiceModule: AnyObject {
    var view: UIView? { get }
    var serviceType: ServiceType { get }
    var result: Result<IService, ErrorResponse>? { get }
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

///Controller which manages `IServiceModule`s.
///Configured by `ServiceModuleBuilder`
protocol IServiceController: AnyObject {
    var modules: [IServiceModule] { get }
    var user: UserProxy? { get }
    func moduleDidUpdated(_ module: IServiceModule)
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
