import UIKit
import class MapKit.MKMapView
import DesignKit

final class MapModuleView: BaseView {
    let label = UILabel()
    let map = MKMapView()

    override func addViews() {
        addSubviews(label, map)
    }

    override func configureLayout() {
        label.edgesToSuperview(excluding: .bottom, usingSafeArea: true)

        map.edgesToSuperview(excluding: .top, usingSafeArea: true)
        map.height(400)
        map.topToBottom(of: label, offset: 10)
    }

    override func configureAppearance() {
        label.font = .toyotaType(.semibold, of: 20)
        label.textColor = .appTint(.signatureGray)
        label.textAlignment = .left
        label.backgroundColor = .systemBackground

        map.mapType = .hybrid
        map.layer.cornerRadius = 15
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.isRotateEnabled = true
        map.isUserInteractionEnabled = true
        map.showsCompass = true
    }

    override func localize() {
        label.text = .common(.enterLocation)
    }
}
