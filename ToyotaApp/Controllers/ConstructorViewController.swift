import UIKit

class ConstructorViewController: UIViewController {
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    
    private var serviceTypeId: String!
    private var showroomId: String!
    
    func configure(with serviceType: String, and showroom: String) {
        serviceTypeId = serviceType
        showroomId = showroom
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    func completion(response: ServicesDidGetResponse?) {
        DispatchQueue.main.async { [self] in
            
            indicatorView.stopAnimating()
            indicatorView.isHidden = true
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
