//
//  AccountsTableViewController.swift
//  WAAccountStoreDemo
//
//  Created by YuAo on 5/24/15.
//  Copyright (c) 2015 YuAo. All rights reserved.
//

import UIKit
import WAAccountStore

class AccountsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WAAccountStore.default().accounts.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        
        let account = WAAccountStore.default().accounts[indexPath.row]
        cell.textLabel?.text = account.user.name
        cell.detailTextLabel?.text = account.identifier

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Swipe: Delete. Tap: Become current account", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let account = WAAccountStore.default().accounts[indexPath.row]
            WAAccountStore.default().removeAccount(withIdentifier: account.identifier)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let account = WAAccountStore.default().accounts[indexPath.row]
        WAAccountStore.default().currentAccount = account
        self.tableView.reloadData()
    }
}
