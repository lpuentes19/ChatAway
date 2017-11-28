//
//  User.swift
//  ChatAway
//
//  Created by Luis Puentes on 11/1/17.
//  Copyright © 2017 LuisPuentes. All rights reserved.
//

import Foundation

class UserModel {
    
    var name: String?
    var email: String?
    var id: String?
    var profileImageURL: String?
    
    init(dictionary: [String: Any]) {
        id = dictionary["id"] as? String
        name = dictionary["name"] as? String
        email = dictionary["email"] as? String
        profileImageURL = dictionary["profileImageURL"] as? String
    }
}
