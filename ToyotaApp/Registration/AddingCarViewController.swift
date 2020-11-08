import UIKit

class AddingCarViewController: UIViewController {
    
    @IBOutlet private(set) var carsList: UICollectionView!
    
    var cars: [Car]?
    private let cellIdentifier = CellIdentifiers.CarChoosingCell
    private let endRegisterSegueCode = SegueIdentifiers.CarToEndRegistration
    private let checkCarSegueCode = SegueIdentifiers.CarToCheckVin
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case checkCarSegueCode:
                if let cell = sender as? CarChoosingCell {
                    let vc = segue.destination as? CheckVinViewController
                    vc!.car = cell.cellCar
                }
            default: return
        }
    }
}

extension AddingCarViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cars!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = cars![indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! CarChoosingCell
        cell.configureCell(car: item, checkVinFunc: cellButtonAction)
        return cell
    }
    
    private func cellButtonAction(sender: UICollectionViewCell) {
        DispatchQueue.main.async { [self] in
            performSegue(withIdentifier: checkCarSegueCode, sender: sender)
        }
    }
}
