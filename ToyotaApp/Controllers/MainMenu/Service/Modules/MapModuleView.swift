import UIKit
import class MapKit.MKMapView

final class MapModuleView: BaseView {
    let label: UILabel = {
        let label = UILabel()
        label.font = .toyotaType(.semibold, of: 20)
        label.textColor = .label
        label.textAlignment = .left
        label.text = .common(.enterLocation)
        return label
    }()

    let map: MKMapView = {
        let map = MKMapView()
        map.mapType = .hybrid
        map.layer.cornerRadius = 15
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.isRotateEnabled = true
        map.isUserInteractionEnabled = true
        map.showsCompass = true
        return map
    }()

    override class var requiresConstraintBasedLayout: Bool {
        true
    }

    override func addViews() {
        addSubviews(label, map)
    }

    override func configureLayout() {
        label.edgesToSuperview(excluding: .bottom, usingSafeArea: true)

        map.edgesToSuperview(excluding: .top, usingSafeArea: true)
        map.height(400)
        map.topToBottom(of: label, offset: 10)
    }
}
