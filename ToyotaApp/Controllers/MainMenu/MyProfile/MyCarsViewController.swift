import UIKit

class MyCarsViewController: UIViewController, BackgroundText {
    @IBOutlet private(set) var carsCollection: UICollectionView!
    @IBOutlet var addShowroomButton: UIBarButtonItem!
    
    private let cellIdentrifier = CellIdentifiers.CarCell
    private var user: UserProxy! {
        didSet { subscribe(on: user) }
    }
    
    private var cars: [Car] { user.getCars.array }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if cars.isEmpty {
            carsCollection.backgroundView = createBackground(with: "Здесь будут отображаться Ваши автомобили. Как только Вы их добавите.")
        } else {
            carsCollection.backgroundView = nil
        }
    }
    
    @IBAction func addCar(sender: Any?) {
        NetworkService.shared.makePostRequest(page: RequestPath.Profile.getCities, params:
            [URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.id)], completion: completion)
    }
    
    func completion(response: ProfileDidSetResponse?) {
        DispatchQueue.main.async { [self] in
            guard response?.error_code == nil, let cities = response?.cities else {
                PopUp.displayMessage(with: "Ошибка", description: response?.message ?? "Ошибка при загрузке городов", buttonText: "Ок")
                return
            }
            let register = UIStoryboard(name: AppStoryboards.register, bundle: nil)
            let addShowroomVC =  register.instantiateViewController(identifier: AppViewControllers.dealerViewController) as! DealerViewController
            addShowroomVC.configure(cityList: cities, controllerType: .next(with: user))
            navigationController?.pushViewController(addShowroomVC, animated: true)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension MyCarsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        cars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentrifier, for: indexPath) as! CarCollectionViewCell
        let car = cars[indexPath.row]
        cell.configure(brand: car.brand, model: car.model, color: car.color, plate: car.plate, colorDesription: car.colorDescription, vin: car.vin)
        return cell
    }
}

//MARK: - WithUserInfo
extension MyCarsViewController: WithUserInfo {
    func subscribe(on proxy: UserProxy) {
        proxy.getNotificator.add(observer: self)
    }
    
    func unsubscribe(from proxy: UserProxy) {
        proxy.getNotificator.remove(obsever: self)
    }
    
    func userDidUpdate() {
        carsCollection.reloadData()
    }
    
    func setUser(info: UserProxy) {
        user = info
    }
}
