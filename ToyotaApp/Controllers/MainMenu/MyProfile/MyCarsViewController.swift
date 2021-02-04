import UIKit

class MyCarsViewController: UIViewController {
    @IBOutlet private(set) var carsCollection: UICollectionView!
    @IBOutlet var addShowroomButton: UIBarButtonItem!
    @IBOutlet var indicator: UIActivityIndicatorView!
    
    private let cellIdentrifier = CellIdentifiers.CarCell
    private var cars: UserInfo.Cars = UserInfo.Cars()
    
    override func viewWillAppear(_ animated: Bool) {
        indicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(with: UserInfo.Cars) { cars = with }
    
    @IBAction func addCar(sender: Any?) {
        indicator.startAnimating()
        indicator.isHidden = false
        NetworkService.shared.makePostRequest(page: RequestPath.Profile.getCities, params:
            [URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.id)], completion: completion)
    }
    
    func completion(response: ProfileDidSetResponse?) {
        guard response?.error_code == nil, let cities = response?.cities else {
            indicator.stopAnimating()
            PopUp.displayMessage(with: "Ошибка", description: response?.message ?? "Ошибка при загрузке городов", buttonText: "Ок")
            return
        }
        DispatchQueue.main.async { [self] in
            let register = UIStoryboard(name: AppStoryboards.register, bundle: nil)
            let addShowroomVC =  register.instantiateViewController(identifier: AppViewControllers.dealerViewController) as! DealerViewController
            addShowroomVC.configure(cityList: cities, controllerType: .next)
            navigationController?.pushViewController(addShowroomVC, animated: true)
        }
    }
}

extension MyCarsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars.array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentrifier, for: indexPath) as! CarCollectionViewCell
        let car = cars.array[indexPath.row]
        cell.configure(brand: car.brand, model: car.model, color: car.color, plate: car.plate, colorDesription: car.colorDescription, vin: car.vin)
        return cell
    }
}
