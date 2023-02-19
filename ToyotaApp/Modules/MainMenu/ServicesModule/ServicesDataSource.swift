import UIKit

enum ServiceSections: Int {
    case main
}

typealias ServicesDataSource = CVDataSource<ServiceSections, ServiceType>
typealias ServiceTypeCellRegistration = CVCellRegistration<ServiceTypeCell, ServiceType>

extension ServicesDataSource {
    convenience init(_ collectionView: UICollectionView) {
        self.init(
            collectionView: collectionView,
            cellProvider: ServicesCellProvider.make()
        )
    }

    enum ServicesCellProvider {
        static func make() -> ServicesDataSource.CellProvider {
            let registration = ServiceTypeCellRegistration { cell, _, item in
                cell.configure(name: item.name)
            }

            return { collectionView, indexPath, item in
                collectionView.dequeueConfiguredReusableCell(
                    using: registration,
                    for: indexPath,
                    item: item
                )
            }
        }
    }
}
