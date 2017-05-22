//
//  User.swift
//  toDoFirebase
//
//  Created by Dimz on 17.05.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import Foundation
import Firebase

struct User {

    var uid: String
    var email: String
    
    init(user: FIRUser) {
        self.uid = user.uid
        self.email = user.email ?? ""
    }

}
