//
//  Resource.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 03/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class Resource: Object {
    
    var parent = LinkingObjects(fromType: Resource.self, property: "children")
    var children = List<Resource>()
    dynamic var name: String = ""
    dynamic var path: String = ""
    dynamic var type: String = ""
    dynamic var mimeType: String = ""
    dynamic var size: Int = 0
    dynamic var created: String = ""
    dynamic var modified: String = ""
    
    convenience init(name: String, path: String, type: String, mimeType: String, size: Int, created: String, modified: String, parent: Resource?) {
        self.init()
        self.name = name
        self.path = path
        self.type = type
        self.mimeType = mimeType
        self.size = size
        self.created = created
        self.modified = modified
        //self.parent = parent
    }
    
}
