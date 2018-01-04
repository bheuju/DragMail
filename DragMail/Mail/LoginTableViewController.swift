//
//  LoginTableViewController.swift
//  DragMail
//
//  Created by Mac on 1/4/18.
//  Copyright © 2018 Mac. All rights reserved.
//

import UIKit
import Postal

enum LoginError: Error {
    case badEmail
    case badPassword
    case badHostname
    case badPort
}

extension LoginError: CustomStringConvertible {
    var description: String {
        switch self {
        case .badEmail: return "Bad mail"
        case .badPassword: return "Bad password"
        case .badHostname: return "Bad hostname"
        case .badPort: return "Bad port"
        }
    }
}

final class LoginTableViewController: UITableViewController {
    fileprivate let mailsSegueIdentifier = "mailsSegue"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var hostnameTextField: UITextField!
    @IBOutlet weak var portTextField: UITextField!
    
    var provider: MailProvider?
}

// MARK: - View lifecycle
extension LoginTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let provider = provider, let configuration = provider.preConfiguration {
            emailTextField.placeholder = "exemple@\(provider.hostname)"
            hostnameTextField.isUserInteractionEnabled = false
            hostnameTextField.text = configuration.hostname
            portTextField.isUserInteractionEnabled = false
            portTextField.text = "\(configuration.port)"
        }
    }
}

// MARK: - Navigation management

// MARK: - Helpers
private extension LoginTableViewController {
    
    func createConfiguration() throws -> Configuration {
        guard let email = emailTextField.text , !email.isEmpty else { throw LoginError.badEmail  }
        guard let password = passwordTextField.text , !password.isEmpty else { throw LoginError.badPassword }
        
        if let configuration = provider?.preConfiguration {
            return Configuration(hostname: configuration.hostname, port: configuration.port, login: email, password: .plain(password), connectionType: configuration.connectionType, checkCertificateEnabled: configuration.checkCertificateEnabled)
        } else {
            guard let hostname = hostnameTextField.text , !hostname.isEmpty else { throw LoginError.badHostname }
            guard let portText = portTextField.text , !portText.isEmpty else { throw LoginError.badPort }
            guard let port = UInt16(portText) else { throw LoginError.badPort }
            
            return Configuration(hostname: hostname, port: port, login: email, password: .plain(""), connectionType: .tls, checkCertificateEnabled: true)
        }
    }
}

