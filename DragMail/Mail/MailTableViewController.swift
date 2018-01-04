//
//  MailViewController.swift
//  DragMail
//
//  Created by Mac on 1/3/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Postal

enum MailProvider: Int {
    case icloud
    case google
    case outlook
    
    var hostname: String {
        switch self {
        case .icloud: return "icloud.com"
        case .google: return "gmail.com"
        case .outlook: return "outlook.com"
        }
    }
    
    var preConfiguration: Configuration? {
        switch self {
        case .icloud: return .icloud(login: "", password: "")
        case .google: return .gmail(login: "", password: .plain(""))
        case .outlook: return .outlook(login: "", password: "")
        }
    }
}

class MailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @objc func displayDragMailBoard() {
        //Push DragMail VC
        let dragMailVC = DragMailViewController(nibName: "DragMailViewController", bundle: nil)
        self.navigationController?.pushViewController(dragMailVC, animated: true)
    }
    
    @IBAction func onLoginClicked(_ sender: UIButton) {
        
        let postal = Postal(configuration: .gmail(login: "es.bishal.heuju@gmail.com", password: .plain("")))
        postal.connect { (result) in
            switch result {
            case .success:
                print("Success")
                
                sender.isUserInteractionEnabled = false
                sender.setTitle("es.bishal.heuju@gmail.com", for: .normal)
                sender.backgroundColor = UIColor.green
                
                //Fetch last 5 messages
                postal.fetchLast("Inbox", last: 5, flags: [.fullHeaders, .body], onMessage: { (email) in
                    print("UID: #\(email.uid) Subject: \(email.header!.subject)")
                    self.emails.insert(email, at: 0)
                    
                    //Insert to main Data array
                    //Insert all emails into TODO by default
                    Data.shared.list.first?.items.insert(email, at: 0)
                    
                }, onComplete: { (error) in
                    if let error = error {
                        print("Error in email: ", error)
                    } else {
                        //No error
                        self.mailTableView.reloadData()
                        
                        //display Dragmail board on successful login
                        self.displayDragMailBoard()
                    }
                })
                
            case .failure(let error):
                print("Failed with errror: ", error)
            }
        }
    }
}

//MARK:- TableView Delegate
extension MailTableViewController {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let provider = MailProvider(rawValue: (indexPath as NSIndexPath).row) else { fatalError("Unknown provider") }
        print("selected provider: \(provider)")
        
        performSegue(withIdentifier: loginSegueIdentifier, sender: provider.rawValue)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}


