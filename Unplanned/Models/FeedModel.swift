//
//  FeedModel.swift
//  Unplanned
//
//  Created by matata on 02.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import UIKit
import Localize_Swift

class FeedModel: NSObject {

    var title : String!
    var imageIconName : String!
    var imageBackgroundName : String!
    var type : String!
    var foursquareID : String!
    
    
    init(_title: String, _imageIconName : String, _imageBackgroundName : String, _type: String, _foursquareId : String) {
        self.title = _title
        self.imageIconName = _imageIconName
        self.imageBackgroundName = _imageBackgroundName
        self.type = _type
        self.foursquareID = _foursquareId
    }
}
