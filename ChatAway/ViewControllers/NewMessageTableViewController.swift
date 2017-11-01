//
//  NewMessageTableViewController.swift
//  ChatAway
//
//  Created by Luis Puentes on 11/1/17.
//  Copyright © 2017 LuisPuentes. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class NewMessageTableViewController: UITableViewController {

    let cellID = "cellID"
    var users = [UserModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        tableView.register(UserDetailTableViewCell.self, forCellReuseIdentifier: cellID)
        
        fetchUser()
    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        Database.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let user = UserModel()

                user.name = dict["name"] as? String
                user.email = dict["email"] as? String

                self.users.append(user)
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email

        return cell
    }
}
