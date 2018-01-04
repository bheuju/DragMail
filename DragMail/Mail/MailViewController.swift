//
//  MailViewController.swift
//  DragMail
//
//  Created by Mac on 1/3/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Postal

class MailViewController: UIViewController {

    @IBOutlet weak var mailTableView: UITableView!
    
    var emails: [FetchResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set tableview delegate and datasource
        mailTableView.delegate = self
        mailTableView.dataSource = self
        
        mailTableView.rowHeight = UITableViewAutomaticDimension
        mailTableView.estimatedRowHeight = 80
        
        //Register cell
        mailTableView.register(UINib(nibName: "MailTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        //Config navBar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Board", style: .plain, target: self, action: #selector(displayDragMailBoard))
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

extension MailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! MailTableViewCell
        
        let email = emails[indexPath.row]
        
        cell.emailTitle.text = email.header?.subject
        
        let from = email.header?.from.first
        
        cell.emailDetails.text = "\(from!.displayName) \n<\(from!.email)>"
        
        return cell
    }
    
    
}
