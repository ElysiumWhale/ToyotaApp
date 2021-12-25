import UIKit

class MyCarsViewController: UIViewController, Loadable {

    @IBOutlet private(set) var carsCollection: UICollectionView!
    @IBOutlet var addShowroomButton: UIBarButtonItem!

    private(set) lazy var loadingView: LoadingView = {
        LoadingView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
    }()

    private let cellIdentifier = CellIdentifiers.CarCell
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var cars: [Car] { user.getCars.array }

    private lazy var citiesRequestHandler: RequestHandler<ModelsAndColorsResponse> = {
        RequestHandler<ModelsAndColorsResponse>()
            .bind { [weak self] data in
                DispatchQueue.main.async {
                    self?.handle(data)
                }
            } onFailure: { error in
                PopUp.display(.error(description: error.message ?? .error(.citiesLoadError)))
            }
    }()

    private lazy var removeCarHandler: RequestHandler<Response> = {
        RequestHandler<Response>() .bind(onFailure: { [weak self] error in
            DispatchQueue.main.async {
                self?.stopLoading()
            }
            PopUp.display(.error(description: .error(.requestError)))
        })
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        carsCollection.delaysContentTouches = false
        carsCollection.setBackground(text: cars.isEmpty ? .background(.noCars) : nil)
    }

    @IBAction func addCar(sender: Any?) {
        NetworkService.makeRequest(page: .registration(.getModelsAndColors),
                                   params: [(.auth(.brandId), Brand.Toyota)],
                                   handler: citiesRequestHandler)
    }

    @IBAction func doneDidPress(_ sender: Any) {
        dismiss(animated: true)
    }

    private func handle(_ response: ModelsAndColorsResponse) {
        let register = UIStoryboard(.register)
        let addCarVC: AddCarViewController = register.instantiate(.addCar)
        addCarVC.configure(models: response.models, colors: response.colors,
                           controllerType: .update(with: user))
        navigationController?.pushViewController(addCarVC, animated: true)
    }

    private func removeCar(with id: String) {
        removeCarHandler.onSuccess = { [weak self] _ in
            self?.user.removeCar(with: id)
            DispatchQueue.main.async {
                self?.stopLoading()
            }
        }

        PopUp.display(.choise(description: .question(.removeCar))) { [self] in
            startLoading()
            NetworkService.makeRequest(page: .profile(.removeCar),
                                       params: [(.auth(.userId), user.getId),
                                                (.carInfo(.carId), id)],
                                       handler: removeCarHandler)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension MyCarsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cars.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CarCollectionViewCell = collectionView.dequeue(for: indexPath)
        let car = cars[indexPath.row]
        cell.configure(brand: car.brand, model: car.model.name,
                       color: car.color.name, plate: car.plate,
                       colorDesription: car.color.colorDescription,
                       showroom: "Салон")
        cell.removeAction = { [weak self] in
            self?.removeCar(with: car.id)
        }
        return cell
    }
}

// MARK: - WithUserInfo
extension MyCarsViewController: WithUserInfo {
    func subscribe(on proxy: UserProxy) {
        proxy.getNotificator.add(observer: self)
    }

    func unsubscribe(from proxy: UserProxy) {
        proxy.getNotificator.remove(obsever: self)
    }

    func userDidUpdate() {
        DispatchQueue.main.async { [self] in
            carsCollection.reloadData()
            carsCollection.setBackground(text: cars.isEmpty ? .background(.noCars) : nil)
        }
    }

    func setUser(info: UserProxy) {
        user = info
    }
}
