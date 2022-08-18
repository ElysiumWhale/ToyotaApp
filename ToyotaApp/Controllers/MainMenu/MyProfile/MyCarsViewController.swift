import UIKit

final class MyCarsViewController: UIViewController, Loadable {
    private let carsService: CarsService = InfoService()
    private let modelsAndColorsHandler = RequestHandler<ModelsAndColorsResponse>()
    private let removeCarHandler = DefaultRequestHandler()

    @IBOutlet private(set) var carsCollection: UICollectionView!
    @IBOutlet var addShowroomButton: UIBarButtonItem!

    let loadingView = LoadingView()

    private var user: UserProxy! {
        didSet {
            EventNotificator.shared.add(self, for: .userUpdate)
        }
    }

    private var cars: [Car] { user.cars.value }
    private var deleteCarClosure: Closure?

    var isLoading: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        setupRequestHandlers()
        carsCollection.delaysContentTouches = false
        carsCollection.setBackground(text: cars.isEmpty ? .background(.noCars) : nil)
    }

    @IBAction func addCar(sender: Any?) {
        startLoading()
        carsService.getModelsAndColors(with: .init(brandId: Brand.Toyota),
                                       handler: modelsAndColorsHandler)
    }

    @IBAction func doneDidPress(_ sender: Any) {
        dismiss(animated: true)
    }

    private func setupRequestHandlers() {
        modelsAndColorsHandler
            .observe(on: .main, mode: .onSuccess)
            .bind { [weak self] response in
                self?.handle(response)
            } onFailure: { [weak self] error in
                self?.stopLoading()
                PopUp.display(.error(description: error.message ?? .error(.citiesLoadError)))
            }

        removeCarHandler
            .observe(on: .main)
            .bind { [weak self] _ in
                self?.deleteCarClosure?()
                self?.stopLoading()
            } onFailure: { [weak self] error in
                self?.stopLoading()
                PopUp.display(.error(description: error.message ?? .error(.requestError)))
            }
    }

    private func handle(_ response: ModelsAndColorsResponse) {
        stopLoading()
        let vc = RegisterFlow.addCarModule(scenario: .update(with: user),
                                           models: response.models,
                                           colors: response.colors)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func removeCar(with id: String) {
        deleteCarClosure = { [self] in
            user.removeCar(with: id)
            deleteCarClosure = nil
        }

        PopUp.display(.choise(description: .question(.removeCar))) { [self] in
            startLoading()
            carsService.removeCar(with: .init(userId: user.id, carId: id),
                                  handler: removeCarHandler)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MyCarsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        cars.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CarCollectionViewCell = collectionView.dequeue(for: indexPath)
        let car = cars[indexPath.row]
        cell.configure(with: car)
        cell.removeAction = { [weak self] in
            self?.removeCar(with: car.id)
        }
        return cell
    }
}

// MARK: - WithUserInfo
extension MyCarsViewController: WithUserInfo {
    func setUser(info: UserProxy) {
        user = info
    }
}

extension MyCarsViewController: ObservesEvents {
    func handle(event: EventNotificator.AppEvents, notificator: EventNotificator) {
        switch event {
        case .userUpdate:
            dispatch { [self] in
                carsCollection.reloadData()
                carsCollection.setBackground(text: cars.isEmpty ? .background(.noCars) : nil)
            }
        default:
            return
        }
    }
}
