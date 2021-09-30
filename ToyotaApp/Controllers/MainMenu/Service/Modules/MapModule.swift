import UIKit
import MapKit

// MARK: - View
class MapModuleView: UIView {
    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.toyotaType(.semibold, of: 20)
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

// MARK: - Module
class MapModule: NSObject, IServiceModule {
    var view: UIView? { internalView }

    private lazy var internalView: MapModuleView = {
        let map = MapModuleView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.alpha = 0
        map.map.delegate = self
        return map
    }()

    private var locationManager: CLLocationManager!
    private var isInitiallyZoomedToUserLocation: Bool = false

    private(set) var serviceType: ServiceType
    private(set) var state: ModuleStates = .idle {
        didSet {
            delegate?.moduleDidUpdate(self)
        }
    }

    internal weak var delegate: IServiceController?

    init(with type: ServiceType) {
        serviceType = type
    }

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
                default: return
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
        if !isInitiallyZoomedToUserLocation {
            isInitiallyZoomedToUserLocation = true
            let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            internalView.map.setRegion(viewRegion, animated: true)
        }
    }
}
