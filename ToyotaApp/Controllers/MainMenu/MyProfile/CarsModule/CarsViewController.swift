import UIKit

final class CarsViewController: BaseViewController, Loadable {
    private let interactor: CarsInteractor
    private let carsCollection = UICollectionView(layout: .carsLayout)

    let loadingView = LoadingView()

    var isLoading: Bool = false

    init(interactor: CarsInteractor) {
        self.interactor = interactor

        super.init()
    }

    override func addViews() {
        addDismissRightButton()
        addSubviews(carsCollection)

        let action = UIAction(handler: { [weak self] _ in
            self?.addNewCar()
        })
        let buttonItem = UIBarButtonItem(title: .common(.add),
                                         primaryAction: action)
        buttonItem.tintColor = .appTint(.secondarySignatureRed)
        navigationItem.leftBarButtonItem = buttonItem

        carsCollection.registerCell(CarCell.self)
        carsCollection.dataSource = self
    }

    override func configureLayout() {
        carsCollection.edgesToSuperview(usingSafeArea: false)
    }

    override func configureAppearance() {
        view.backgroundColor = .systemGroupedBackground
        carsCollection.backgroundColor = .systemGroupedBackground
        carsCollection.showsVerticalScrollIndicator = false

        carsCollection.setBackground(text: interactor.cars.isEmpty ? .background(.noCars) : nil)
    }

    override func localize() {
        navigationItem.title = .common(.myCars)
        navigationItem.backButtonTitle = .empty
    }

    override func configureActions() {
        EventNotificator.shared.add(self, for: .userUpdate)

        interactor.onRemoveCar = { [weak self] in
            self?.stopLoading()
        }

        interactor.onModelsAndColorsLoad = { [weak self] response in
            self?.handle(response)
        }

        interactor.onRequestError = { [weak self] message in
            self?.stopLoading()
            PopUp.display(.error(description: message))
        }
    }

    @objc private func addNewCar() {
        startLoading()
        interactor.getModelsAndColors()
    }

    private func removeCar(with id: String) {
        PopUp.display(.choise(description: .question(.removeCar))) { [self] in
            startLoading()
            interactor.removeCar(with: id)
        }
    }

    private func handle(_ response: ModelsAndColorsResponse) {
        stopLoading()
        let vc = RegisterFlow.addCarModule(scenario: .update(with: interactor.user),
                                           models: response.models,
                                           colors: response.colors)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension CarsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        interactor.cars.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CarCell = collectionView.dequeue(for: indexPath)
        let car = interactor.cars[indexPath.row]
        cell.configure(car: car)
        cell.removeAction = { [weak self] in
            self?.removeCar(with: car.id)
        }
        return cell
    }
}

extension CarsViewController: ObservesEvents {
    func handle(event: EventNotificator.AppEvents, notificator: EventNotificator) {
        switch event {
        case .userUpdate:
            dispatch { [self] in
                carsCollection.reloadData()
                carsCollection.setBackground(text: interactor.cars.isEmpty ? .background(.noCars) : nil)
            }
        default:
            return
        }
    }
}
