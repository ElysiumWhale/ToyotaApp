import UIKit
import MapKit

class HelpOnRoadViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet private(set) var mapView: RoundedMKMapView!
    @IBOutlet private(set) var requestButton: UIButton!
    
    var locationManager: CLLocationManager!
    var isInitiallyZoomedToUserLocation: Bool = false
    
    private var serviceType: ServiceType!
    private var selectedCar: Car!
    
    override func viewWillDisappear(_ animated: Bool) {
        isInitiallyZoomedToUserLocation = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let locManager = CLLocationManager()
        mapView.delegate = self
        navigationItem.title = "Вызов эвакуатора"
        locManager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            mapView.showsUserLocation = true
            locationManager = locManager
            DispatchQueue.main.async { [self] in
                locationManager.startUpdatingLocation()
                
                if let coordinate = locationManager.location?.coordinate {
                    zoomToUserLocation(coordinate)
                }
            }
        } else {
           // Do something to let users know why they need to turn it on.
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            switch manager.authorizationStatus {
                case .authorizedAlways, .authorizedWhenInUse:
                    mapView.showsUserLocation = true
                case .notDetermined, .denied, .restricted:
                    manager.requestWhenInUseAuthorization()
                default: return
            }
            
//            switch manager.accuracyAuthorization {
//                case .fullAccuracy:
//                    break
//                case .reducedAccuracy:
//                    break
//                default:
//                    break
//            }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        zoomToUserLocation(userLocation.coordinate)
    }
    
    func zoomToUserLocation(_ coordinate: CLLocationCoordinate2D) {
        if !isInitiallyZoomedToUserLocation {
           isInitiallyZoomedToUserLocation = true
            let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    @IBAction func makeRequest(sender: UIButton) {
        PopUp.displayMessage(with: "Заявка отправлена", description: "В ближайшее время с Вами свяжется менеджер, также будет вызван эвакуатор", buttonText: CommonText.ok)
    }
}

//MARK: - ServicesMapped
extension HelpOnRoadViewController: ServicesMapped {
    func configure(with service: ServiceType, car: Car) {
        serviceType = service
        selectedCar = car
    }
}

