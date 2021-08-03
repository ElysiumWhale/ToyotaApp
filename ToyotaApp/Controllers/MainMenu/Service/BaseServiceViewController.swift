import UIKit

// MARK: Controller
class BaseServiceController: UIViewController, IServiceController {
    private(set) var scrollView = UIScrollView()
    private(set) var stackView = UIStackView()

    private(set) lazy var bookButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.mainAppTint
        button.titleLabel?.font = UIFont.toyotaType(.semibold, of: 20)
        button.layer.cornerRadius = 20
        button.setTitle("Оставить заявку", for: .normal)
        button.addAction { [self] in
            bookService()
        }
        button.isHidden = true
        return button
    }()

    private(set) var serviceType: ServiceType?
    private(set) var user: UserProxy?
    private(set) var modules: [IServiceModule] = []

    override func viewDidLoad() {
        navigationItem.title = serviceType?.serviceTypeName
        navigationItem.backButtonTitle = "Услуги"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        hideKeyboardWhenTappedAround()
        setupScrollViewLayout()
        scrollView.addSubview(stackView)
        setupStackViewLayout()
        start()
    }

    func start() {
        for module in modules {
            stackView.addArrangedSubview(module.view ?? UIView())
        }
        stackView.addArrangedSubview(bookButton)
        modules.first?.start()
    }

    func configure(with service: ServiceType, modules: [IServiceModule], user: UserProxy) {
        self.modules = modules
        self.user = user
        self.serviceType = service
    }

    func moduleDidUpdated(_ module: IServiceModule) {
        var message: String = "Ошибка при запросе данных"
        switch module.result {
            case .failure(let error):
                if let mes = error.message { message = mes }
                fallthrough
            case .none:
                PopUp.displayMessage(with: CommonText.error, description: message, buttonText: CommonText.ok) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            case .success:
                guard let index = modules.firstIndex(where: { $0 === module }) else { return }
                if index + 1 == modules.count {
                    bookButton.fadeIn(0.6)
                    return
                }
                modules[index + 1].start(with: module.buildQueryItems())
        }
    }

    func bookService() {
        guard let userId = user?.getId, let showroomId = user?.getSelectedShowroom?.id else { return }
        
        var params: [URLQueryItem] = [URLQueryItem(name: RequestKeys.Auth.userId, value: userId),
                                      URLQueryItem(name: RequestKeys.CarInfo.showroomId, value: showroomId)]
        
        for module in modules {
            let items = module.buildQueryItems()
            if items.count < 1 { return }
            params.append(contentsOf: items)
        }
        
        if params.first(where: { $0.name == RequestKeys.Services.serviceId }) == nil {
            params.append(URLQueryItem(name: RequestKeys.Services.serviceId, value: serviceType!.id))
        }
        
        NetworkService.shared.makePostRequest(page: RequestPath.Services.bookService, params: params, completion: completion)
        
        func completion(for response: Result<Response, ErrorResponse>) {
            switch response {
                case .success:
                    PopUp.displayMessage(with: CommonText.success,description: "Заявка оставлена и будет обработана в ближайшее время", buttonText: CommonText.ok) { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    PopUp.displayMessage(with: CommonText.error, description: error.message ?? CommonText.servicesError, buttonText: CommonText.ok)
            }
        }
    }
}

// MARK: Constraints setup
extension BaseServiceController {
    private func setupScrollViewLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
    }

    private func setupStackViewLayout() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillProportionally
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -40)
        ])
    }
}
