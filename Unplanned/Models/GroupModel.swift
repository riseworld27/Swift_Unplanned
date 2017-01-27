//
//  GroupModelTable.swift
//  Unplanned
//
//  Created by matata on 30.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class GroupModel: Object {

    dynamic var titleGroup: String! = ""
    dynamic var imageUrlGroup: String! = ""
    dynamic var idGroup: String! = ""
    dynamic var typeGroup: String! = ""

    convenience init(_idGroup : String, _titleGroup : String, _typeGroup : String, _imageUrlGroup : String) {

        self.init ()

        self.titleGroup = _titleGroup
        self.imageUrlGroup = _imageUrlGroup
        self.idGroup = _idGroup
        self.typeGroup = _typeGroup
    }

    override static func primaryKey() -> String? {
        return "idGroup"
    }
}
