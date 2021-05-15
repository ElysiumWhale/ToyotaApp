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
        carsCollection.backgroundView = cars.isEmpty ? createBackground(labelText: "Здесь будут отображаться Ваши автомобили. Как только Вы их добавите.") : nil
    }
    
    @IBAction func addCar(sender: Any?) {
        NetworkService.shared.makePostRequest(page: RequestPath.Profile.getCities, params:
            [URLQueryItem(name: RequestKeys.Auth.brandId, value: Brand.Toyota)], completion: carDidAddCompletion)
    }
    
    private func carDidAddCompletion(for response: Result<ProfileDidSetResponse, ErrorResponse>) {
        switch response {
            case .success(let data):
                DispatchQueue.main.async { [self] in
                    let register = UIStoryboard(name: AppStoryboards.register, bundle: nil)
                    let addShowroomVC =  register.instantiateViewController(identifier: AppViewControllers.dealer) as! DealerViewController
                    addShowroomVC.configure(cityList: data.cities, controllerType: .update(with: user))
                    navigationController?.pushViewController(addShowroomVC, animated: true)
                }
            case .failure(let error):
                displayError(with: error.message ?? "Ошибка при загрузке городов, повторите позднее")
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
        DispatchQueue.main.async { [self] in
            carsCollection.reloadData()
        }
    }
    
    func setUser(info: UserProxy) {
        user = info
    }
}
