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
    var messagesDictionary = [String: Message]()
    let image = UIImage(named: "newMessage")
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
        tableView.register(UserDetailTableViewCell.self, forCellReuseIdentifier: cellID)
        
        tableView.allowsMultipleSelectionDuringEditing = true // Need to set in order to reveal the delete button
        
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let ref = Database.database().reference().child("User-Messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            let userID = snapshot.key
            
            Database.database().reference().child("User-Messages").child(uid).child(userID).observe(.childAdded, with: { (snapshot) in
                let messageID = snapshot.key
                self.fetchMessageWithMessageID(messageID: messageID)
            })
        })
    }
    
   private func fetchMessageWithMessageID(messageID: String) {
        let messageRef = Database.database().reference().child("Messages").child(messageID)
        
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let message = Message(dictionary: dict)
                
                if let chatPartnerID = message.chatPartnerID() {
                    self.messagesDictionary[chatPartnerID] = message
                }
                self.attemptReloadOfTable()
            }
        })
    }
    
    func attemptReloadOfTable() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        
        // Sorting messages by timestamp
        // self.messages.sort(by: { (message1, message2) -> Bool in
        //      return message1.timestamp?.intValue > message2.timestamp?.intValue
        // })
        tableView.reloadData()
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: Any] {
                self.navigationItem.title = dict["name"] as? String
                self.messages.removeAll()
                self.messagesDictionary.removeAll()
                self.tableView.reloadData()
                self.observeUserMessages()
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
        return messages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? UserDetailTableViewCell else { return UITableViewCell() }

        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerID = message.chatPartnerID() else { return }
        
        let ref = Database.database().reference().child("Users").child(chatPartnerID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dict = snapshot.value as? [String: Any] else { return }
            
            let user = UserModel(dictionary: dict)
            user.id = chatPartnerID
            self.showChatLogVCForUser(user: user)
        })
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let message = self.messages[indexPath.row]
        if let chatPartnerID = message.chatPartnerID() {
            Database.database().reference().child("User-Messages").child(uid).child(chatPartnerID).removeValue(completionBlock: { (error, ref) in
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                self.messagesDictionary.removeValue(forKey: chatPartnerID)
                self.attemptReloadOfTable()
//                self.messages.remove(at: indexPath.row)
//                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
