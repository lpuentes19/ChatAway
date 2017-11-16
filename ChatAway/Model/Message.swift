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
    
    func chatPartnerID() -> String? {
        if fromID == Auth.auth().currentUser?.uid {
            return toID
        } else {
            return fromID
        }
    }
}
