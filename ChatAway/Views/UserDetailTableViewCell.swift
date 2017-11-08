//
//  UserDetailTableViewCell.swift
//  ChatAway
//
//  Created by Luis Puentes on 11/1/17.
//  Copyright © 2017 LuisPuentes. All rights reserved.
//

import UIKit
import FirebaseDatabase

class UserDetailTableViewCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            if let toID = message?.toID {
                let ref = Database.database().reference().child("Users").child(toID)
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dict = snapshot.value as? [String : Any] {
                        self.textLabel?.text = dict["name"] as? String
                        
                        if let profileImageURL = dict["profileImageURL"] as? String {
                            self.profileImageView.loadImageUsingCacheWith(urlString: profileImageURL)
                        }
                    }
                })
            }
            detailTextLabel?.text = message?.text
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
