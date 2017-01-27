//
//  UserModel.swift
//  Unplanned
//
//  Created by True Metal on 5/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import Parse

class UserModel: PFUser
{
    override class func initialize() {
        struct Static { static var onceToken : dispatch_once_t = 0; }
        dispatch_once(&Static.onceToken) { self.registerSubclass() }
    }
    
    @NSManaged var isProfileCreated:Bool
    @NSManaged var firstName: String?
    @NSManaged var lastName: String?
    @NSManaged var birthday: NSDate?
    @NSManaged var photo:PFFile?
    
    @NSManaged var digitsUserId:String?
    @NSManaged var allFriends:NSArray?
    
    // MARK: facility
    
    var fullName:String { get
    {
        var name = firstName ?? ""
        if let lastName = lastName { name = name + " \(lastName)" }
        return name
        }
    }
}
