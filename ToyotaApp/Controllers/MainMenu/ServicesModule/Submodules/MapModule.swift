import UIKit
import MapKit

final class MapModule: NSObject, IServiceModule {
    var view: UIView { internalView }

    private lazy var internalView: MapModuleView = {
        let map = MapModuleView()
        map.alpha = 0
        map.map.delegate = self
        map.map.isUserInteractionEnabled = false
        return map
    }()

    private let locationManager = CLLocationManager()
    private var isInitiallyZoomedToUserLocation: Bool = false

    private(set) var state: ModuleStates = .idle {
        didSet {
            delegate?.moduleDidUpdate(self)
        }
    }

    weak var nextModule: IServiceModule?
    weak var delegate: ModuleDelegate?

    func start(with params: RequestItems) {
        locationManager.delegate = self
        locationManagerDidChangeAuthorization(locationManager)
        internalView.fadeIn()
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

// MARK: - CLLocationManagerDelegate
extension MapModule: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async {
                self.internalView.map.showsUserLocation = true
                self.internalView.map.isUserInteractionEnabled = true
            }
            state = .didChose(Service.empty)
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            DispatchQueue.main.async {
                self.internalView.map.isUserInteractionEnabled = false
            }
            // In another case popup is not shown
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.state = .block(.error(.geoRestriction))
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
        let viewRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 300,
            longitudinalMeters: 300
        )
        internalView.map.setRegion(viewRegion, animated: true)
    }
}
