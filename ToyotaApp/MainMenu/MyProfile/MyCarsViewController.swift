import UIKit

class MyCarsViewController: UIViewController {
    @IBOutlet private(set) var carsCollection: UICollectionView!
    
    let cellIdentrifier = CellIdentifiers.CarChoosingCell
    private var cars: UserInfo.Cars = UserInfo.Cars()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func configure(with: UserInfo.Cars) {
       cars = with
    }
    
    @IBAction func addCar(sender: Any?) {
        PopUpPreset.display(with: "Добавить машину", description: "Скоро здесь можно будет добавить машину", buttonText: "Ок")
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
