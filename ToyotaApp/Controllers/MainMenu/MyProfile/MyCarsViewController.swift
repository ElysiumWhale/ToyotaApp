import UIKit

class MyCarsViewController: UIViewController, BackgroundText {
    @IBOutlet private(set) var carsCollection: UICollectionView!
    @IBOutlet var addShowroomButton: UIBarButtonItem!

    private let cellIdentifier = CellIdentifiers.CarCell
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var cars: [Car] { user.getCars.array }

    private lazy var citiesRequestHandle: RequestHandler<CitiesDidGetResponse> = {
        let handler = RequestHandler<CitiesDidGetResponse>()
        
        handler.onSuccess = { [weak self] data in
            DispatchQueue.main.async {
                self?.handle(data)
            }
        }
        
        handler.onFailure = { error in
            PopUp.display(.error(description: error.message ?? .error(.citiesLoadError)))
        }
        
        return handler
    }()

    private lazy var removeCarHandler: RequestHandler<Response> = {
        let handler = RequestHandler<Response>()

        handler.onFailure = { error in
            // hide loading view
            PopUp.display(.error(description: .error(.requestError)))
        }

        return handler
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        carsCollection.backgroundView = cars.isEmpty ? createBackground(labelText: .background(.noCars))
                                                     : nil
    }

    @IBAction func addCar(sender: Any?) {
        NetworkService.makeRequest(page: .profile(.getCities),
                                   params: [(.auth(.brandId), Brand.Toyota)],
                                   handler: citiesRequestHandle)
    }

    @IBAction func doneDidPress(_ sender: Any) {
        dismiss(animated: true)
    }

    private func handle(_ response: CitiesDidGetResponse) {
        let register = UIStoryboard(.register)
        let addShowroomVC: DealerViewController = register.instantiate(.dealer)
        addShowroomVC.configure(cityList: response.cities, controllerType: .update(with: user))
        navigationController?.pushViewController(addShowroomVC, animated: true)
    }

    private func removeCar(with id: String) {
        removeCarHandler.onSuccess = { [weak self] _ in
            self?.user.remove(carId: id)
        }
        
        PopUp.displayChoice(with: .common(.confirmation),
                            description: .question(.removeCar),
                            confirmText: .common(.yes),
                            declineText: .common(.cancel),
                            confirmCompletion: { [self] in
            // add loading view
            NetworkService.makeRequest(page: .profile(.removeCar),
                                       params: [(.auth(.userId), user.getId),
                                                (.carInfo(.carId), id)],
                                       handler: removeCarHandler)
        })
    }
}

// MARK: - UICollectionViewDataSource
extension MyCarsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cars.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CarCollectionViewCell = collectionView.dequeue(for: indexPath)
        let car = cars[indexPath.row]
        let showroomName = user.getShowrooms.value.first(where: {$0.id == car.showroomId})?.showroomName
        cell.configure(brand: car.brand, model: car.model,
                       color: car.color, plate: car.plate,
                       colorDesription: car.colorDescription,
                       showroom: showroomName ?? "Салон")
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
            carsCollection.backgroundView = cars.isEmpty ? createBackground(labelText: .background(.noCars))
                                                         : nil
        }
    }

    func setUser(info: UserProxy) {
        user = info
    }
}
