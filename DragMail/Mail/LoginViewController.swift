//
//  LoginViewController.swift
//  DragMail
//
//  Created by Mac on 1/4/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Postal

class LoginViewController: UIViewController {

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    //MARK:- Injection
    var mailProvider: MailProvider? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let provider = mailProvider {
            logo.image = provider.logo
            email.placeholder = "example@\(provider.hostname)"
        }
        
        //prototype data
        email.text = ""
        password.text = ""
    }
    
    @IBAction func onLoginClicked(_ sender: UIButton) {
        
        //create configuration with email and password
        guard let userEmail = email.text, !userEmail.isEmpty else { return }
        guard let userPassword = password.text, !userPassword.isEmpty else { return }
        
        guard let configuration = mailProvider?.preConfiguration else {
            return
        }
        
        let newConfig = Configuration(
            hostname: configuration.hostname,
            port: configuration.port,
            login: userEmail,
            password: .plain(userPassword),
            connectionType: configuration.connectionType,
            checkCertificateEnabled: configuration.checkCertificateEnabled)
        
        print("Config: ", newConfig)
        
        let postal = Postal(configuration: newConfig)
        postal.connect { (result) in
            switch result {
            case .success:
                print("Success")
                
                //Fetch last 5 messages
                postal.fetchLast("Inbox", last: 5, flags: [.fullHeaders, .body], onMessage: { (email) in
                    print("UID: #\(email.uid) Subject: \(email.header!.subject)")
                    
                    //Insert to main Data array
                    //Insert all emails into TODO by default
                    Data.shared.list.first?.items.insert(email, at: 0)
                    
                }, onComplete: { (error) in
                    if let error = error {
                        print("Error in email: ", error)
                    } else {
                        //No error, Fetching emails complete
                        print("Email fetch complete")
                        
                        //Push DragMail VC
                        let dragMailVC = DragMailViewController(nibName: "DragMailViewController", bundle: nil)
                        self.navigationController?.pushViewController(dragMailVC, animated: true)
                    }
                })
                
            case .failure(let error):
                print("Failed with errror: ", error)
            }
        }
    }
}
