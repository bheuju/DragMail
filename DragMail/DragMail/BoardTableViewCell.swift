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
    @IBOutlet weak var btnCheckBox: UIButton!
    
    @IBOutlet weak var cellContainerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellContainerView.layer.cornerRadius = 5
        cellContainerView.layer.borderWidth = 0.5
        cellContainerView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    @IBAction func btnCheckBoxClicked(_ sender: UIButton) {
        //TODO: Set checkStatus to true in BoardItemViewModel
        sender.setImage(#imageLiteral(resourceName: "checkbox_true"), for: .normal) //FIXME: Remove this
    }
    
    //MARK:- Configure cell
    func configCell(item: BoardItemViewModel) {
        
        let from = item.mailResult!.header?.from.first
        
        self.sender.text = from!.displayName
        self.subject.text = item.mailResult?.header?.subject
        self.emailDescription.text = from!.email
        
        let checkBoxImage = (item.checkStatus ? #imageLiteral(resourceName: "checkbox_true") : #imageLiteral(resourceName: "checkbox_false"))
        self.btnCheckBox.setImage(checkBoxImage, for: .normal)
    }
}
