import UIKit

class MyCarsViewController: UIViewController {
    @IBOutlet private(set) var carsCollection: UICollectionView!
    
    private let cellIdentrifier = CellIdentifiers.CarCell
    private var cars: UserInfo.Cars = UserInfo.Cars()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configure(with: UserInfo.Cars) { cars = with }
    
    @IBAction func addCar(sender: Any?) {
        PopUpPreset.display(with: "Добавить машину", description: "Скоро здесь можно будет добавить машину", buttonText: "Ок")
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
