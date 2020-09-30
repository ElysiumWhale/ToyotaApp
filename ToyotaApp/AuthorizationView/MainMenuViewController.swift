import UIKit

class MainMenuViewController: UIViewController {
    
    @IBOutlet var myCarButton: UIButton!
    
    @IBOutlet var techButton: UIButton!
    
    @IBOutlet var serviceButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCarButton.layer.cornerRadius = 10
        myCarButton.clipsToBounds = true
        techButton.layer.cornerRadius = 10
        techButton.clipsToBounds = true
        serviceButton.layer.cornerRadius = 10
        serviceButton.clipsToBounds = true
    }
    
    @IBAction func myCarButtonTapped(sender: UIButton){
        
    }

}
