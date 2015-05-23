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
    private(set) var name: String?
    private(set) var email: String?
    
    override init() {
        super.init()
    }
    
    init (name: String, email: String) {
        super.init()
        self.name = name
        self.email = email
    }

    required init!(dictionary dictionaryValue: [NSObject : AnyObject]!, error: NSErrorPointer) {
        super.init(dictionary: dictionaryValue, error: error)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadCurrentAccountInfo()
    }
    
    func reloadCurrentAccountInfo() {
        if let currentAccount = WAAccountStore.defaultStore().currentAccount {
            self.textView.text = "ID:\(currentAccount.identifier)\nName:\(currentAccount.user.name!)\nEmail:\(currentAccount.user.email!)\nAccessToken:\(currentAccount.credential.accessToken)"
        } else {
            self.textView.text = "No Accounts"
        }
    }

    @IBAction func addAccountButtonTapped(sender: AnyObject) {
        let alertController = UIAlertController(title: "Add Account", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            //AccountID
            textField.text = NSProcessInfo.processInfo().globallyUniqueString
            textField.enabled = false
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Name"
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Email"
        }
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "AccessToken"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
            
        }))
        alertController.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            //AccountID
            let accountID = (alertController.textFields![0] as! UITextField).text
            
            //Name
            let name = (alertController.textFields![1] as! UITextField).text
            
            //Email
            let email = (alertController.textFields![2] as! UITextField).text

            //AccessToken
            let token = (alertController.textFields![3] as! UITextField).text
            
            let account = WAAccount(
                identifier: accountID,
                credential: WAAccountCredential(identifier: accountID, accessToken: token),
                user: User(name: name, email: email))
            WAAccountStore.defaultStore().addAccount(account)
            self.reloadCurrentAccountInfo()
        }))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

}

