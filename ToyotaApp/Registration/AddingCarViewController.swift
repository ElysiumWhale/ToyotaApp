import UIKit
import SwiftEntryKit

class AddingCarViewController: UIViewController {
    
    @IBOutlet private(set) var carsList: UICollectionView!
    
    var cars: [Car]?
    private let cellIdentifier = CellIdentifiers.CarChoosingCell
    private let endRegisterSegueCode = SegueIdentifiers.CarToEndRegistration
    private let checkCarSegueCode = SegueIdentifiers.CarToCheckVin
    
    private var alertShown = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !alertShown {
        SwiftEntryKit.display(entry: EKPopUpMessageView(with: setupNotificationMessage()), using: setupNotificationPopup())
            alertShown = true
        }
    }
    
    private func setupNotificationMessage() -> EKPopUpMessage {
        let titleLabel = EKProperty.LabelContent(text: "Добавьте машину", style: EKProperty.LabelStyle(font: UIFont.boldSystemFont(ofSize: 20), color: EKColor(light: .black, dark: .white)))
        let descrLabel = EKProperty.LabelContent(text: "Выберите машину из списка и подтвердите ее владение с помощью VIN-кода", style: EKProperty.LabelStyle(font: UIFont.boldSystemFont(ofSize: 20), color: EKColor(light: .black, dark: .white)))
        let button = EKProperty.ButtonContent(label: .init(text: "Ок", style: .init(font: UIFont.boldSystemFont(ofSize: 20), color: .black)), backgroundColor: .init(UIColor.systemTeal), highlightedBackgroundColor: .clear)
        return EKPopUpMessage(title: titleLabel, description: descrLabel, button: button, action: { SwiftEntryKit.dismiss() })
    }
    
    private func setupNotificationPopup() ->  EKAttributes {
        var attr = EKAttributes.centerFloat
        attr.displayDuration = .infinity
        attr.screenBackground = .color(color: .init(light: UIColor(white: 100.0/255.0, alpha: 0.3), dark: UIColor(white: 50.0/255.0, alpha: 0.3)))
        attr.shadow = .active(with: .init(color: .black, opacity: 0.3, radius: 8))
        attr.screenInteraction = .dismiss
        attr.entryInteraction = .absorbTouches
        attr.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attr.entranceAnimation = .init(translate: .init(duration: 0.7,  spring: .init(damping: 1, initialVelocity: 0)), scale: .init(from: 1.05, to: 1, duration: 0.4, spring: .init(damping: 1, initialVelocity: 0)))
        attr.exitAnimation = .init(translate: .init(duration: 0.2))
        attr.popBehavior = .animated(animation: .init(translate: .init(duration: 0.2)))
        attr.positionConstraints.verticalOffset = 50
        attr.statusBar = .dark
        return attr
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case checkCarSegueCode:
                if let cell = sender as? CarChoosingCell {
                    let vc = segue.destination as? CheckVinViewController
                    vc!.car = cell.cellCar
                    vc!.parentDelegate = self
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

extension AddingCarViewController : AddingCarDelegate {
    func carDidChecked() {
        DispatchQueue.main.async { [self] in
            performSegue(withIdentifier: endRegisterSegueCode, sender: nil)
        }
    }
}
