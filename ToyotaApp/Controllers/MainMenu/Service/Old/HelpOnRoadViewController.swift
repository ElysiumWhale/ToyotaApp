import UIKit
import MapKit

class HelpOnRoadViewController: UIViewController {
    @IBOutlet private var mapView: RoundedMKMapView!
    @IBOutlet private var requestButton: UIButton!
    
    private var locationManager: CLLocationManager!
    private var isInitiallyZoomedToUserLocation: Bool = false
    private var serviceType: ServiceType!
    private var selectedCar: Car!
    
    override func viewWillDisappear(_ animated: Bool) {
        isInitiallyZoomedToUserLocation = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let locManager = CLLocationManager()
        locManager.delegate = self
        mapView.delegate = self
        navigationItem.title = "Вызов эвакуатора"
        if CLLocationManager.locationServicesEnabled() {
            mapView.isUserInteractionEnabled = true
            mapView.showsUserLocation = true
            locationManager = locManager
            DispatchQueue.main.async { [self] in
                locationManager.startUpdatingLocation()
                if let coordinate = locationManager.location?.coordinate {
                    zoomToUserLocation(coordinate)
                }
            }
        } else {
            PopUp.displayMessage(with: "Предупреждение", description: "Для использования услуги Помощь на дороге необходимо предоставить доступ к геопозиции", buttonText: CommonText.ok)
            mapView.isUserInteractionEnabled = false
        }
    }
    
    @IBAction private func makeRequest(sender: UIButton) {
        PopUp.displayMessage(with: "Заявка отправлена", description: "В ближайшее время с Вами свяжется менеджер, также будет вызван эвакуатор", buttonText: CommonText.ok)
    }
}

//MARK: - CLLocationManagerDelegate
extension HelpOnRoadViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.showsUserLocation = true
            case .notDetermined, .denied, .restricted:
                manager.requestWhenInUseAuthorization()
            default: return
        }
    }
}

//MARK: - MKMapViewDelegate
extension HelpOnRoadViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        zoomToUserLocation(userLocation.coordinate)
    }
    
    private func zoomToUserLocation(_ coordinate: CLLocationCoordinate2D) {
        if !isInitiallyZoomedToUserLocation {
            isInitiallyZoomedToUserLocation = true
            let viewRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
}
