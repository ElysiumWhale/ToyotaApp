import Foundation
import UIKit
import MapKit

// MARK: - View
class MapModuleView: UIView {
    private(set) lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.toyotaType(.semibold, of: 20)
        label.textColor = .label
        label.textAlignment = .left
        label.text = "Укажите местоположение"
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
    
    private(set) var result: Result<IService, ErrorResponse>?
    
    private(set) weak var delegate: IServiceController?
    
    init(with type: ServiceType, for controller: IServiceController) {
        serviceType = type
        delegate = controller
    }
    
    func start(with params: [URLQueryItem]) {
        let locManager = CLLocationManager()
        locManager.delegate = self
        internalView.fadeIn()
        if CLLocationManager.locationServicesEnabled() {
            internalView.map.showsUserLocation = true
            locationManager = locManager
            locationManager.startUpdatingLocation()
            if let coordinate = locationManager.location?.coordinate {
                zoomToUserLocation(coordinate)
            }
            result = .success(Service(id: "0", name: "Success"))
            delegate?.moduleDidUpdated(self)
        } else {
            PopUp.displayMessage(with: "Предупреждение",
                                 description: "Для использования услуги Помощь на дороге необходимо предоставить доступ к геопозиции",
                                 buttonText: CommonText.ok)
            internalView.map.isUserInteractionEnabled = false
            result = .failure(ErrorResponse(code: "-1", message: "Нет доступа к геолокации"))
            delegate?.moduleDidUpdated(self)
        }
    }
    
    func buildQueryItems() -> [URLQueryItem] {
        guard locationManager.authorizationStatus == .authorizedAlways ||
              locationManager.authorizationStatus == .authorizedWhenInUse,
              let latitude = locationManager.location?.coordinate.latitude,
              let longitude = locationManager.location?.coordinate.longitude else {
            return []
        }
        
        return [URLQueryItem(name: RequestKeys.Services.latitude,
                             value: latitude.description),
                URLQueryItem(name: RequestKeys.Services.longitude,
                             value: longitude.description)]
    }
    
    func configureViewText(with labelText: String) {
        internalView.label.text = labelText
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

// MARK: - CLLocationManagerDelegate
extension MapModule: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                internalView.map.showsUserLocation = true
            case .notDetermined, .denied, .restricted:
                manager.requestWhenInUseAuthorization()
            default: return
        }
    }
}
