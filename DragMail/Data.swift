//
//  Data.swift
//  DragMail
//
//  Created by Mac on 1/2/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation

class Data {
    static let shared = Data()
    
    var list = [
        BoardEmailItem(title: "TODO", items: []),
        BoardEmailItem(title: "Process", items: []),
        BoardEmailItem(title: "Completed", items: [])
    ]
    
//    var list = [
//        BoardItem(title: "TODO", items: ["TODO 1", "TODO 2"]),
//        BoardItem(title: "Process", items: ["Doing 1", "Doing 2", "Doing 3"]),
//        BoardItem(title: "Completed", items: ["Done 1"]),
//        BoardItem(title: "New", items: ["New Item 1"]),
//        BoardItem(title: "Misc", items: ["Apple"])
//    ]
}
