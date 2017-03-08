//
// Created by Mikhail Mulyar on 20/06/16.
// Copyright (c) 2016 matata. All rights reserved.
//

import RealmSwift

class RealmUserModel: Object {

	dynamic var username: String = ""
	dynamic var objectId: String = ""

	dynamic var name: String = ""
	dynamic var photoUrl: String = ""
	dynamic var isAdded: Bool = false
	dynamic var groupsString: String = ""

	var groups : [String] {

		set {
			groupsString = (newValue as NSArray).componentsJoined(by: "&")
		}

		get {
			return self.groupsString.components(separatedBy: "&")
		}
	}

	func addGroup (_ group : String) {

		var groups = self.groups

		if (!groups.contains(group)) {

			groups.append(group)

			self.groups = groups
		}
	}

	func removeGroup (_ group : String) {

		var groups = self.groups

		if (groups.contains(group)) {

			groups.removeObject(group)

			self.groups = groups
		}
	}

	convenience init(_objectId: String, _userName: String, _name: String, _imageUrl: String, _isAdded: Bool) {

		self.init()

		self.name = _name
		self.photoUrl = _imageUrl
		self.username = _userName
		self.objectId = _objectId
		self.isAdded = _isAdded
	}

	override static func primaryKey() -> String? {
		return "objectId"
	}

	override class func ignoredProperties() -> [String] {
		return ["groups"]
	}
}
