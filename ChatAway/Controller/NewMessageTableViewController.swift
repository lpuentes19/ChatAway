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
    var messagesController: MessagesTableViewController?
    
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
                user.id = snapshot.key
                user.profileImageURL = dict["profileImageURL"] as? String

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserDetailTableViewCell else { return UITableViewCell() }
        
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        guard let profileImageURL = user.profileImageURL else { return UITableViewCell() }
            cell.profileImageView.loadImageUsingCacheWith(urlString: profileImageURL)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatLogVCForUser(user: user)
        }
    }
}


