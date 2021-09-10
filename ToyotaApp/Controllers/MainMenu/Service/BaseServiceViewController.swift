import UIKit

// MARK: Controller
class BaseServiceController: UIViewController, IServiceController {
    private(set) var scrollView = UIScrollView()
    private(set) var stackView = UIStackView()

    private(set) lazy var bookButton: BookButton = {
        let button = BookButton()
        button.backgroundColor = UIColor.appTint(.mainRed)
        button.titleLabel?.font = UIFont.toyotaType(.semibold, of: 20)
        button.layer.cornerRadius = 20
        button.setTitle("Оставить заявку", for: .normal)
        button.addAction { [weak self] in
            self?.bookService()
        }
        button.alpha = 0
        return button
    }()
    
    lazy var loadingView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        indicator.color = .white
        view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        indicator.startAnimating()
        view.backgroundColor = UIColor.appTint(.loading)
        view.alpha = 0
        return view
    }()

    private(set) var serviceType: ServiceType?
    private(set) var user: UserProxy?
    private(set) var modules: [IServiceModule] = []

    init(_ service: ServiceType, _ modules: [IServiceModule], _ user: UserProxy) {
        super.init(nibName: nil, bundle: .main)
        self.modules = modules
        self.user = user
        self.serviceType = service
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationItem.title = serviceType?.serviceTypeName
        navigationItem.backButtonTitle = "Услуги"
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        hideKeyboardWhenTappedAround()
        setupScrollViewLayout()
        scrollView.addSubview(stackView)
        setupStackViewLayout()
        view.addSubview(loadingView)
        loadingView.fadeIn()
        start()
    }

    func start() {
        stackView.addArrangedSubview(modules.first?.view ?? UIView())
        modules.first?.start()
    }

    func configure(with service: ServiceType, modules: [IServiceModule], user: UserProxy) {
        self.modules = modules
        self.user = user
        self.serviceType = service
    }

    func moduleDidUpdate(_ module: IServiceModule) {
        switch module.state {
            case .idle: return
            case .didDownload:
                DispatchQueue.main.async { [weak self] in
                    self?.loadingView.fadeOut {
                        self?.loadingView.removeFromSuperview()
                    }
                }
            case .error(let error):
                PopUp.display(.error(description: error.message ?? AppErrors.unknownError.rawValue)) { [weak self] in
                    self?.loadingView.fadeOut {
                        self?.loadingView.removeFromSuperview()
                    }
                    self?.navigationController?.popViewController(animated: true)
                }
            case .block(let message):
                DispatchQueue.main.async { [weak self] in
                    self?.loadingView.fadeOut {
                        self?.loadingView.removeFromSuperview()
                    }
                    if self?.modules.last === module {
                        self?.bookButton.fadeIn()
                    }
                    self?.bookButton.isEnabled = false
                }
                PopUp.display(.warning(description: message ?? AppErrors.requestError.rawValue))
            case .didChose:
                guard let index = modules.firstIndex(where: { $0 === module }) else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let controller = self else { return }
                    if index + 1 == controller.modules.count {
                        controller.loadingView.fadeOut {
                            controller.loadingView.removeFromSuperview()
                        }
                        if !controller.stackView.arrangedSubviews.contains(controller.bookButton) {
                            controller.stackView.addArrangedSubview(controller.bookButton)
                        }
                        controller.bookButton.fadeIn()
                        return
                    }
                    controller.view.addSubview(controller.loadingView)
                    controller.loadingView.fadeIn()
                    controller.modules[index + 1].start(with: module.buildQueryItems())
                    controller.stackView.addArrangedSubview(controller.modules[index+1].view ?? UIView())
                }
        }
    }

    func bookService() {
        guard let userId = user?.getId, let showroomId = user?.getSelectedShowroom?.id else { return }
        
        var params: [URLQueryItem] = [URLQueryItem(.auth(.userId), userId),
                                      URLQueryItem(.carInfo(.showroomId), showroomId)]
        
        for module in modules {
            let items = module.buildQueryItems()
            if items.count < 1 { return }
            params.append(contentsOf: items)
        }
        
        if params.first(where: { $0.name == RequestKeys.Services.serviceId.rawValue }) == nil {
            params.append(URLQueryItem(.services(.serviceId), serviceType!.id))
        }
        
        NetworkService.shared.makePostRequest(page: .services(.bookService),
                                              params: params, completion: completion)
        
        func completion(for response: Result<Response, ErrorResponse>) {
            switch response {
                case .success:
                    PopUp.display(.success(description: "Заявка оставлена и будет обработана в ближайшее время"))
                    DispatchQueue.main.async { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    PopUp.display(.error(description: error.message ?? CommonText.servicesError))
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
