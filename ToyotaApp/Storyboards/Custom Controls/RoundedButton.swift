import UIKit

@IBDesignable class RoundedButton: UIButton
{
    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    //@IBInspectable var cornerRadius: CGFloat = 0
    
    func updateCornerRadius() {
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
    }
}
