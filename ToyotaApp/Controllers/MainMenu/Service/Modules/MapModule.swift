import UIKit
import MapKit

final class MapModule: NSObject, IServiceModule {
    var view: UIView { internalView }

    private lazy var internalView: MapModuleView = {
        let map = MapModuleView()
        map.alpha = 0
        map.map.delegate = self
        return map
    }()

    private var locationManager: CLLocationManager!
    private var isInitiallyZoomedToUserLocation: Bool = false

    private(set) var state: ModuleStates = .idle {
        didSet {
            delegate?.moduleDidUpdate(self)
        }
    }

    weak var nextModule: IServiceModule?
    weak var delegate: ModuleDelegate?

    func start(with params: RequestItems) {
        if CLLocationManager.locationServicesEnabled() {
            let locManager = CLLocationManager()
            locManager.requestWhenInUseAuthorization()
            DispatchQueue.global(qos: .userInitiated).async { [self] in
                while locManager.authorizationStatus == .notDetermined {
                    // nothing
                }
                switch locManager.authorizationStatus {
                    case .authorizedAlways, .authorizedWhenInUse:
                        locationManager = locManager
                        DispatchQueue.main.async { [self] in
                            internalView.map.showsUserLocation = true
                        }
                        state = .didChose(Service.empty)
                    default:
                        DispatchQueue.main.async { [self] in
                            internalView.map.isUserInteractionEnabled = false
                        }
                        state = .block(.error(.geoRestriction))
                }
            }
            internalView.fadeIn()
        } else {
            internalView.map.isUserInteractionEnabled = false
            state = .block(.error(.geoRestriction))
        }
    }

    func buildQueryItems() -> RequestItems {
        guard let latitude = locationManager.location?.coordinate.latitude,
              let longitude = locationManager.location?.coordinate.longitude else {
            return []
        }

        return [(.services(.latitude), latitude.description),
                (.services(.longitude), longitude.description)]
    }

    func configure(appearance: [ModuleAppearances]) {
        for appearance in appearance {
            switch appearance {
            case .title(let title):
                internalView.label.text = title
            default:
                return
            }
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapModule: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        zoomToUserLocation(userLocation.coordinate)
    }

    private func zoomToUserLocation(_ coordinate: CLLocationCoordinate2D) {
        guard !isInitiallyZoomedToUserLocation else {
            return
        }

        isInitiallyZoomedToUserLocation = true
        let viewRegion = MKCoordinateRegion(center: coordinate,
                                            latitudinalMeters: 300,
                                            longitudinalMeters: 300)
        internalView.map.setRegion(viewRegion, animated: true)
    }
}
