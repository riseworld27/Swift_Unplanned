//
//  FeedListModel.swift
//  Unplanned
//
//  Created by matata on 02.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import Parse
import RealmSwift

class FeedListModel: Object {

	dynamic var titleEvent: String!
	dynamic var addressEvent: String!
	dynamic var locationTitleEvent: String!
	dynamic var dateEvent: NSDate!
	dynamic var idEvent: String!
	dynamic var membersString: String!

	dynamic var isMyEvent = false

	dynamic var user: RealmUserModel!

	dynamic var latitude: Double = 0
	dynamic var longitude: Double = 0

	var members : NSArray {

		set {
			membersString = newValue.componentsJoinedByString("&")
		}

		get {

			guard self.membersString != nil else {
				return NSArray()
			}

			return self.membersString.componentsSeparatedByString("&") as NSArray
		}
	}

	override class func ignoredProperties() -> [String] {
		return ["members"]
	}

	override static func primaryKey() -> String? {
		return "idEvent"
	}

	convenience init(_idEvent: String, _titleEvent: String, _addressEvent: String, _locationTitleEvent: String, _isMyEvent: Bool, _user: RealmUserModel, _dateEvent: NSDate, _members: NSArray, _coordinates: PFGeoPoint) {

		self.init()

		self.titleEvent = _titleEvent
		self.idEvent = _idEvent
		self.addressEvent = _addressEvent
		self.isMyEvent = _isMyEvent
		self.user = _user
		self.dateEvent = _dateEvent
		self.locationTitleEvent = _locationTitleEvent
		self.latitude = _coordinates.latitude
		self.longitude = _coordinates.longitude
		self.members = _members
	}
}
