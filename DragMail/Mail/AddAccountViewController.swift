//
//  AddAccountViewController.swift
//  DragMail
//
//  Created by Mac on 1/4/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Postal

class AddAccountViewController: UIViewController {

    @IBOutlet weak var btnOutlook: UIButton!
    @IBOutlet weak var btnICloud: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func btnClicked(_ sender: UIButton) {
        
        switch sender {
            
        case btnOutlook:
            displayLoginViewControllerFor(MailProvider.outlook)
            
        case btnGoogle:
            displayLoginViewControllerFor(MailProvider.google)
            
        case btnICloud:
            displayLoginViewControllerFor(MailProvider.icloud)
            
        default:
            print("Invalid Provider")
        }
    }
    
    func displayLoginViewControllerFor(_ mailProvider: MailProvider) {
        //Push Login VC
        let loginVC = LoginViewController(nibName: "LoginViewController", bundle: nil)
        
        loginVC.mailProvider = mailProvider
        
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
}
