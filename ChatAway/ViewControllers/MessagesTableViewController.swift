//
//  ContactsTableViewController.swift
//  ChatAway
//
//  Created by Luis Puentes on 11/1/17.
//  Copyright © 2017 LuisPuentes. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MessagesTableViewController: UITableViewController {

    let cellID = "cellID"
    var messages = [Message]()
    let image = UIImage(named: "newMessage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserDetailTableViewCell.self, forCellReuseIdentifier: cellID)
        
        checkIfUserIsLoggedIn()
        observeMessages()
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func observeMessages() {
        let ref = Database.database().reference().child("Messages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let message = Message()
                message.toID = dict["toID"] as? String
                message.fromID = dict["fromID"] as? String
                message.text = dict["text"] as? String
                message.timestamp = dict["timestamp"] as? Int
                
                self.messages.append(message)
                self.tableView.reloadData()
            }
        }, withCancel: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                self.navigationItem.title = dict["name"] as? String
            }
        })
    }
    
    @objc func handleNewMessage() {
        let newMessageVC = NewMessageTableViewController()
        newMessageVC.messagesController = self
        let navbarVC = UINavigationController(rootViewController: newMessageVC)
        present(navbarVC, animated: true, completion: nil)
    }

    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginVC = LoginViewController()
        loginVC.messagesController = self
        present(loginVC, animated: true, completion: nil)
    }
    
    func showChatLogVCForUser(user: UserModel) {
        let chatController = ChatLogCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserDetailTableViewCell else { return UITableViewCell() }

        let message = messages[indexPath.row]
        
        if let toID = message.toID {
            let ref = Database.database().reference().child("Users").child(toID)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String : Any] {
                    cell.textLabel?.text = dict["name"] as? String
                }
            })
        }
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
}
