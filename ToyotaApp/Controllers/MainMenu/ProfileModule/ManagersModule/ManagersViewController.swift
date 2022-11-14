import UIKit

final class ManagersViewController: BaseViewController {
    private let managersCollection = CollectionView<ManagerCell>(layout: .managersLayout)

    private let interactor: ManagersInteractor

    init(interactor: ManagersInteractor) {
        self.interactor = interactor

        super.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        managersCollection.dataSource = self

        interactor.getManagers()
    }

    override func addViews() {
        addSubviews(managersCollection)
        addDismissRightButton()
    }

    override func configureLayout() {
        managersCollection.edgesToSuperview()
    }

    override func configureAppearance() {
        view.backgroundColor = .systemGroupedBackground
    }

    override func localize() {
        navigationItem.title = .common(.managersList)
    }

    override func configureActions() {
        interactor.onManagersLoad = { [weak self] in
            self?.reloadCollection()
        }

        interactor.onError = { [weak self] text in
            self?.managersCollection.setBackground(text: text)
        }
    }

    private func reloadCollection() {
        managersCollection.reloadData()
        if interactor.managers.isEmpty {
            managersCollection.setBackground(text: .background(.noManagers))
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ManagersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        interactor.managers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell: ManagerCell = collectionView.dequeue(for: indexPath)
        cell.configure(from: interactor.managers[indexPath.row])
        return cell
    }
}
