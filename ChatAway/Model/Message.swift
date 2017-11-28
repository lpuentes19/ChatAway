//
//  Message.swift
//  ChatAway
//
//  Created by Luis Puentes on 11/6/17.
//  Copyright © 2017 LuisPuentes. All rights reserved.
//

import Foundation
import FirebaseAuth

class Message {
    
    var toID: String?
    var fromID: String?
    var text: String?
    var timestamp: NSNumber?
    var imageURL: String?
    
    init(dictionary: [String: Any]) {
        fromID = dictionary["fromID"] as? String
        text = dictionary["text"] as? String
        toID = dictionary["toID"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        imageURL = dictionary["imageURL"] as? String
    }
    
    func chatPartnerID() -> String? {
        if fromID == Auth.auth().currentUser?.uid {
            return toID
        } else {
            return fromID
        }
    }
}
