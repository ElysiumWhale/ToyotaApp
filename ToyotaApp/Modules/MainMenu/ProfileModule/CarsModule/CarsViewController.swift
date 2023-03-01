import UIKit
import DesignKit

enum CarsOutput: Hashable {
    case addCar(models: [Model], colors: [Color])
}

protocol CarsModule: UIViewController, Outputable<CarsOutput> { }

final class CarsViewController: BaseViewController, Loadable, CarsModule {
    private let interactor: CarsInteractor
    private let carsCollection = CollectionView<CarCell>(layout: .carsLayout)

    let loadingView = LoadingView()

    var output: ParameterClosure<CarsOutput>?

    init(interactor: CarsInteractor, notificator: EventNotificator) {
        self.interactor = interactor

        super.init()

        notificator.add(self, for: .userUpdate)
    }

    override func addViews() {
        addDismissRightButton()
        addSubviews(carsCollection)

        let action = UIAction(handler: { [weak self] _ in
            self?.addNewCar()
        })
        let buttonItem = UIBarButtonItem(
            title: .common(.add),
            primaryAction: action
        )
        buttonItem.tintColor = .appTint(.secondarySignatureRed)
        navigationItem.leftBarButtonItem = buttonItem

        carsCollection.dataSource = self
    }

    override func configureLayout() {
        carsCollection.edgesToSuperview(usingSafeArea: false)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemGroupedBackground
        carsCollection.backgroundColor = .systemGroupedBackground
        carsCollection.showsVerticalScrollIndicator = false
        updateBackground()
    }

    override func localize() {
        navigationItem.title = .common(.myCars)
        navigationItem.backButtonTitle = .empty
    }

    override func configureActions() {
        interactor.onRemoveCar = { [weak self] in
            self?.stopLoading()
        }

        interactor.onModelsAndColorsLoad = { [weak self] response in
            self?.handle(response)
        }

        interactor.onRequestError = { [weak self] message in
            self?.stopLoading()
            PopUp.display(.error(message))
        }
    }

    private func addNewCar() {
        startLoading()
        interactor.getModelsAndColors()
    }

    private func removeCar(with id: String) {
        PopUp.display(.choice(.question(.removeCar))) { [self] in
            startLoading()
            interactor.removeCar(with: id)
        }
    }

    private func handle(_ response: ModelsAndColorsResponse) {
        stopLoading()
        output?(.addCar(models: response.models, colors: response.colors))
    }

    private func updateBackground() {
        let background: BackgroundConfig = interactor.cars.isEmpty
        ? .label(.background(.noCars), .toyotaType(.semibold, of: 25))
        : .empty

        carsCollection.setBackground(background)
    }
}

// MARK: - UICollectionViewDataSource
extension CarsViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        interactor.cars.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: CarCell = collectionView.dequeue(for: indexPath)
        let car = interactor.cars[indexPath.row]
        cell.configure(car: car)
        cell.removeAction = { [weak self] in
            self?.removeCar(with: car.id)
        }
        return cell
    }
}

// MARK: - ObservesEvents
extension CarsViewController: ObservesEvents {
    func handle(
        event: EventNotificator.AppEvents,
        notificator: EventNotificator
    ) {
        switch event {
        case .userUpdate:
            DispatchQueue.main.async { [weak self] in
                self?.carsCollection.reloadData()
                self?.updateBackground()
            }
        default:
            return
        }
    }
}
