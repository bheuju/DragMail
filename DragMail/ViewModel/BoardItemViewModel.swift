//
//  BoardItemViewModel.swift
//  DragMail
//
//  Created by Mac on 1/4/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import Postal

class BoardItemViewModel {
    
    var mailResult: FetchResult? = nil
    var checkStatus: Bool = false
    
    init(mailResult: FetchResult, checkStatus: Bool) {
        self.mailResult = mailResult
        self.checkStatus = checkStatus
    }
}
