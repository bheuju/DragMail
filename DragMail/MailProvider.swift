//
//  MailProvider.swift
//  DragMail
//
//  Created by Mac on 1/4/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import Foundation
import UIKit
import Postal

enum MailProvider: Int {
    case icloud
    case google
    case outlook
    
    var logo: UIImage {
        switch self {
        case .icloud: return #imageLiteral(resourceName: "icloud")
        case .google: return #imageLiteral(resourceName: "google")
        case .outlook: return #imageLiteral(resourceName: "outlook")
        }
    }
    
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
