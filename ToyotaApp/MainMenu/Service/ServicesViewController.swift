import UIKit

class ServicesViewController: UIViewController {
    
    private var userInfo: UserInfo?
    
    let techOverviewSegue = ""
    let feedbackSegue = ""
    let testDriveSegue = ""
    let emergencySegue = ""
    let serviceSegue = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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

extension ServicesViewController: WithUserInfo {
    func setUser(info: UserInfo) {
        userInfo = info
    }
}
