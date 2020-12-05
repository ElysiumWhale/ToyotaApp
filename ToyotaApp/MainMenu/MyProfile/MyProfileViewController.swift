import UIKit

class MyProfileViewController: UIViewController {
    
    @IBOutlet private(set) var firstNameLabel: UILabel!
    @IBOutlet private(set) var secondNameLabel: UILabel!
    @IBOutlet private(set) var lastNameLabel: UILabel!
    
    @IBOutlet private(set) var profilePhoto: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePhoto.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(choosePhoto)))
    }
    
    @objc func choosePhoto(sender: Any?) {
        PopUpPreset.display(with: "Выберите фото", description: "Здесь будет выбор фото", buttonText: "Ок")
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
