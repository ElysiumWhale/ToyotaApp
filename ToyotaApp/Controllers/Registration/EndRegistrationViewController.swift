import UIKit

class EndRegistrationViewController: UIViewController {
    
    @IBAction func loadMainMenu(sender: Any?) {
        #warning("todo send finalize query")
        NavigationService.loadMain(with: Profile(phone: nil, firstName: nil, lastName: nil, secondName: nil, email: nil, birthday: nil), [RegisteredUser.Showroom](), and: [DTOCar]())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
