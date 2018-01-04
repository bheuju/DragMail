//
//  CustomCollectionView.swift
//  DragMail
//
//  Created by Mac on 1/2/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit

class CustomCollectionView: UICollectionView {
    
    var completionBlock: (()->Void)? = nil
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.completionBlock?()
        self.completionBlock = nil
    }
    
    func reloadDataWithCompletion(completionBlock: @escaping () -> Void) {
        self.completionBlock = completionBlock
        super.reloadData()
    }
}
