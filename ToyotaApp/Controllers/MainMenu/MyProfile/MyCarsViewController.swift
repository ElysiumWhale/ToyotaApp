import UIKit

class MyCarsViewController: UIViewController, BackgroundText {
    @IBOutlet private(set) var carsCollection: UICollectionView!
    @IBOutlet var addShowroomButton: UIBarButtonItem!

    private let cellIdentifier = CellIdentifiers.CarCell
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }

    private var cars: [Car] { user.getCars.array }

    override func viewDidLoad() {
        super.viewDidLoad()
        carsCollection.backgroundView = cars.isEmpty ? createBackground(labelText: .background(.noCars))
                                                     : nil
    }

    @IBAction func addCar(sender: Any?) {
        NetworkService.makePostRequest(page: .profile(.getCities),
                                       params: [URLQueryItem(.auth(.brandId), Brand.Toyota)],
                                       completion: carDidAddCompletion)
    }

    @IBAction func doneDidPress(_ sender: Any) {
        dismiss(animated: true)
    }

    private func carDidAddCompletion(for response: Result<CitiesDidGetResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                DispatchQueue.main.async { [weak self] in
                    guard let vc = self else { return }
                    let register = UIStoryboard(name: AppStoryboards.register, bundle: nil)
                    let addShowroomVC = register.instantiateViewController(identifier: AppViewControllers.dealer) as? DealerViewController
                    addShowroomVC?.configure(cityList: data.cities, controllerType: .update(with: vc.user))
                    vc.navigationController?.pushViewController(addShowroomVC!, animated: true)
                }
            case .failure(let error):
                PopUp.display(.error(description: error.message ?? .error(.citiesLoadError)))
        }
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
        }
    }

    func setUser(info: UserProxy) {
        user = info
    }
}
