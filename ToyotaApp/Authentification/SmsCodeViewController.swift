//
//  SmsCodeViewController.swift
//  ToyotaApp
//
//  Created by Алексей Гурин on 08.10.2020.
//  Copyright © 2020 Алексей Гурин. All rights reserved.
//

import UIKit

class SmsCodeViewController: UIViewController {

    @IBOutlet var phoneNumberLabel: UILabel?
    
    var phoneNumber: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func login(with sender: UIButton) {
        // if auth is success
        loadHomeScreen()
    }
    
    func loadHomeScreen() {
        let storyBoard: UIStoryboard = UIStoryboard(name: AppStoryboards.main.rawValue, bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: AppViewControllers.mainMenuNavigation.rawValue)
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(vc)
    }
    
// MARK: - Navigation
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            phoneNumberLabel?.text = phoneNumber
        //
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //switch segue.identifier {}
    }

}
