import UIKit
import MapKit

// MARK: - View
class MapModuleView: UIView {
    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.font = .toyotaType(.semibold, of: 20)
        label.textColor = .label
        label.textAlignment = .left
        label.text = .common(.enterLocation)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private(set) lazy var map: MKMapView = {
        let map = MKMapView()
        map.mapType = .hybrid
        map.layer.cornerRadius = 15
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.isRotateEnabled = true
        map.isUserInteractionEnabled = true
        map.showsCompass = true
        map.translatesAutoresizingMaskIntoConstraints = false
        return map
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureSubviews()
    }

    private func configureSubviews() {
        addSubview(label)
        addSubview(map)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 10),
            map.leadingAnchor.constraint(equalTo: leadingAnchor),
            map.trailingAnchor.constraint(equalTo: trailingAnchor),
            map.bottomAnchor.constraint(equalTo: bottomAnchor),
            map.heightAnchor.constraint(equalToConstant: 500)
        ])
    }

    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
}
