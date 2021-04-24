import UIKit
import MapKit

@IBDesignable class RoundedMKMapView: MKMapView {
    @IBInspectable var rounded: Bool = false {
        didSet { updateCornerRadius() }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = rounded ? 15 : 0
    }
}
