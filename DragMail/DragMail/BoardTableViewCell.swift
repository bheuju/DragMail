//
//  BoardTableViewCell.swift
//  BusinessCalendar
//
//  Created by Mac on 12/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Postal

class BoardTableViewCell: UITableViewCell {

    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var emailDescription: UILabel!
    
    @IBOutlet weak var cellContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellContainerView.layer.cornerRadius = 5
        cellContainerView.layer.borderWidth = 0.5
        cellContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    //MARK:- Configure cell
    func configCell(item: FetchResult) {
        let from = item.header?.from.first
        
        self.sender.text = from!.displayName
        self.subject.text = item.header?.subject
        self.emailDescription.text = from!.email
    }
}
