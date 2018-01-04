//
//  Item.swift
//  DragMail
//
//  Created by Mac on 1/2/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import Postal

class BoardItem {
    
    var title: String = ""
    var items: [String] = []
    
    init(title: String, items: [String]) {
        self.title = title
        self.items = items
    }
}

class BoardEmailItem {
    
    var boardTitle: String = ""
    var items: [FetchResult] = []
    
    init(title: String, items: [FetchResult]) {
        self.boardTitle = title
        self.items = items
    }
}


