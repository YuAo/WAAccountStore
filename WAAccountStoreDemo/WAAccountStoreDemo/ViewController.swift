//
//  ViewController.swift
//  WAAccountStoreDemo
//
//  Created by YuAo on 5/23/15.
//  Copyright (c) 2015 YuAo. All rights reserved.
//

import UIKit
import WAAccountStore
import Mantle

class User: MTLModel {
    fileprivate(set) var name: String?
    fileprivate(set) var email: String?
    
    override init() {
        super.init()
    }
    
    init (name: String, email: String) {
        super.init()
        self.name = name
        self.email = email
    }

    required init(dictionary dictionaryValue: [AnyHashable: Any]!) throws {
        try super.init(dictionary: dictionaryValue)
    }

    required init!(coder: NSCoder!) {
        super.init(coder: coder)
    }
}

extension WAAccount {
    var user: User {
        get {
            return self.userInfo as! User
        }
    }
    
    convenience init(identifier: String, credential: WAAccountCredential, user: User) {
        self.init(identifier: identifier, credential: credential, userInfo: user)
    }
}

let UserAccessTokenStorageKey = "AccessToken"

extension WAAccountCredential {
    var accessToken: String {
        get {
            return self.securityStorage[UserAccessTokenStorageKey] as! String
        }
    }
    
    convenience init(identifier: String, accessToken: String) {
        self.init(identifier: identifier, securityStorage: [UserAccessTokenStorageKey: accessToken])
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadCurrentAccountInfo()
    }
    
    func reloadCurrentAccountInfo() {
        if let currentAccount = WAAccountStore.default().currentAccount {
            self.textView.text = "ID:\(currentAccount.identifier)\nName:\(currentAccount.user.name!)\nEmail:\(currentAccount.user.email!)\nAccessToken:\(currentAccount.credential.accessToken)"
        } else {
            self.textView.text = "No Accounts"
        }
    }
    
    @IBAction func addAccountButtonTapped(_ sender: AnyObject) {
        let alertController = UIAlertController(title: "Add Account", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField { (textField) -> Void in
            //AccountID
            textField.text = ProcessInfo.processInfo.globallyUniqueString
            textField.textColor = UIColor.lightGray
            textField.isEnabled = false
        }
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Name"
        }
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Email"
        }
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "AccessToken"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            
        }))
        alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            //AccountID
            let accountID = (alertController.textFields![0]).text
            
            //Name
            let name = (alertController.textFields![1]).text
            
            //Email
            let email = (alertController.textFields![2]).text

            //AccessToken
            let token = (alertController.textFields![3]).text
            
            let account = WAAccount(
                identifier: accountID!,
                credential: WAAccountCredential(identifier: accountID!, accessToken: token!),
                user: User(name: name!, email: email!))
            WAAccountStore.default().addAccount(account)
            self.reloadCurrentAccountInfo()
        }))
        self.present(alertController, animated: true, completion: nil)
    }

}

