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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WAAccountStore.defaultStore().accounts.count ?? 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) 
        
        let account = WAAccountStore.defaultStore().accounts[indexPath.row]
        cell.textLabel?.text = account.user.name
        cell.detailTextLabel?.text = account.identifier

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Swipe: Delete. Tap: Become current account", comment: "")
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let account = WAAccountStore.defaultStore().accounts[indexPath.row]
            WAAccountStore.defaultStore().removeAccountWithIdentifier(account.identifier)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let account = WAAccountStore.defaultStore().accounts[indexPath.row]
        WAAccountStore.defaultStore().currentAccount = account
        self.tableView.reloadData()
    }
}
