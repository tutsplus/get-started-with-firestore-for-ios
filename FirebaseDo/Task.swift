//
//  Task.swift
//  FirebaseDo
//
//  Created by Doron Katz on 3/27/18.
//  Copyright © 2018 Doron Katz. All rights reserved.
//

import Foundation

struct Task{
    var name:String
    var done: Bool
    var id: String
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "done": done
        ]
    }
}

extension Task{
    init?(dictionary: [String : Any], id: String) {
        guard   let name = dictionary["name"] as? String,
            let done = dictionary["done"] as? Bool
            else { return nil }
        
        self.init(name: name, done: done, id: id)
    }
}
