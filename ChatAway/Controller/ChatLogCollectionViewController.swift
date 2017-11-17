//
//  ChatLogTableViewController.swift
//  ChatAway
//
//  Created by Luis Puentes on 11/6/17.
//  Copyright © 2017 LuisPuentes. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ChatLogCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var user: UserModel? {
        didSet {
            navigationItem.title = user?.name
            observeMessages()
        }
    }
    
    var messages = [Message]()
    let cellID = "cellID"
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
        collectionView?.register(ChatLogCollectionViewCell.self, forCellWithReuseIdentifier: cellID)
        setupInputComponents()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as? ChatLogCollectionViewCell else { return UICollectionViewCell() }
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text {
            height = estimateFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("User-Messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let messageID = snapshot.key
            let messagesRef = Database.database().reference().child("Messages").child(messageID)
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dict = snapshot.value as? [String: Any] else { return }
                let message = Message()
                message.toID = dict["toID"] as? String
                message.fromID = dict["fromID"] as? String
                message.text = dict["text"] as? String
                message.timestamp = dict["timestamp"] as? NSNumber
                
                if message.chatPartnerID() == self.user?.id {
                    self.messages.append(message)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
            })
        })
    }
    
    func setupInputComponents() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorLineView)
        
        separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func handleSend() {
        guard let text = inputTextField.text else { return }
        if text == "" {
            return
        } else {
            let ref = Database.database().reference().child("Messages")
            let childRef = ref.childByAutoId()
            let toID = user!.id!
            let fromID = Auth.auth().currentUser!.uid
            let timestamp: Int = Int(NSDate().timeIntervalSince1970)
            let values = ["text": text, "toID": toID, "fromID": fromID, "timestamp": timestamp] as [String : Any]
            
            childRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print(error!.localizedDescription)
                    return
                }
                let userMessagesRef = Database.database().reference().child("User-Messages").child(fromID)
                
                let messageID = childRef.key
                userMessagesRef.updateChildValues([messageID: 1])
                
                let recipientUserMessagesRef = Database.database().reference().child("User-Messages").child(toID)
                recipientUserMessagesRef.updateChildValues([messageID: 1])
            })
        }
    }
}
