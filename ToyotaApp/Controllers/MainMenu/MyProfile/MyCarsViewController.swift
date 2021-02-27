import UIKit

class MyCarsViewController: UIViewController, BackgroundText {
    @IBOutlet private(set) var carsCollection: UICollectionView!
    @IBOutlet var addShowroomButton: UIBarButtonItem!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    private let cellIdentrifier = CellIdentifiers.CarCell
    private var user: UserInfo!
    
    override func viewWillAppear(_ animated: Bool) {
        indicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if user.cars.value.array.isEmpty {
            carsCollection.backgroundView = createBackground(with: "Здесь будут отображаться Ваши автомобили. Как только Вы их добавите.")
        } else {
            carsCollection.backgroundView = nil
        }
    }
    
    @IBAction func addCar(sender: Any?) {
        indicator.startAnimating()
        indicator.isHidden = false
        NetworkService.shared.makePostRequest(page: RequestPath.Profile.getCities, params:
            [URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.id)], completion: completion)
    }
    
    func completion(response: ProfileDidSetResponse?) {
        DispatchQueue.main.async { [self] in
            guard response?.error_code == nil, let cities = response?.cities else {
                indicator.stopAnimating()
                PopUp.displayMessage(with: "Ошибка", description: response?.message ?? "Ошибка при загрузке городов", buttonText: "Ок")
                return
            }
            let register = UIStoryboard(name: AppStoryboards.register, bundle: nil)
            let addShowroomVC =  register.instantiateViewController(identifier: AppViewControllers.dealerViewController) as! DealerViewController
            addShowroomVC.configure(cityList: cities, controllerType: .next)
            navigationController?.pushViewController(addShowroomVC, animated: true)
        }
    }
    
    #warning("to-do: rework")
    func addCar(_ car: Car, _ showroom: Showroom) {
        if user.showrooms.value.firstIndex(where: { $0.id == showroom.id }) == nil {
            var showrooms = user.showrooms.value
            showrooms.append(showroom)
            //user.update(showrooms: showrooms)
        }
        var cars = user.cars.value
        cars.array.append(car)
        //user.update(cars: cars)
        if let tabBatController = parent?.parent as? UITabBarController {
            tabBatController.updateControllers(with: user)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension MyCarsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return user.cars.value.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentrifier, for: indexPath) as! CarCollectionViewCell
        let car = user.cars.value.array[indexPath.row]
        cell.configure(brand: car.brand, model: car.model, color: car.color, plate: car.plate, colorDesription: car.colorDescription, vin: car.vin)
        return cell
    }
}

//MARK: - WithUserInfo
extension MyCarsViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        user = info
    }
}
