//
//  ContactUserModel.swift
//  Unplanned
//
//  Created by matata on 01.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation

class ContactUserModel: NSObject {
    var objectId : String!
    var name : String!
    var imageUrl : String!
    var isAdded : Bool!
    var username : String!
    
    init(_name : String, _imageUrl : String, _isAdded : Bool ) {
        self.name = _name
        self.imageUrl = _imageUrl
        self.isAdded = _isAdded
    }
    
    init(_objectId: String, _userName : String, _name : String, _imageUrl : String, _isAdded : Bool ) {
        self.name = _name
        self.imageUrl = _imageUrl
        self.isAdded = _isAdded
        self.username = _userName
        self.objectId = _objectId
    }
}
