//
//  Task.swift
//  toDoFirebase
//
//  Created by Dimz on 17.05.17.
//  Copyright © 2017 Dmitriy Zyablikov. All rights reserved.
//

import Foundation
import Firebase

struct Task {
    
    let title: String
    let userId: String
    let ref: FIRDatabaseReference?
    
    var completed = false
    
    init(title: String, userId: String) {
        self.title = title
        self.userId = userId
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String : AnyObject]
        title = snapshotValue["title"] as! String
        userId = snapshotValue["userId"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func convertToDictionary() -> Any {
        return ["title" : title, "userId" : userId, "completed" : completed]
    }
}
