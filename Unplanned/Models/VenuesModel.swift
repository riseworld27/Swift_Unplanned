//
//  VenuesModel.swift
//  Unplanned
//
//  Created by matata on 02.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import SwiftyJSON
/*
 Rate limits are 5000 userless calls per hour -> each call inside a multi call will count as more than one call
 We can increase the # of calls by talking to them, but they recommend to sign the users because then you can do 500 requests per user instead. Also there
 results can be more personalized. 120k calls per day, if we sign them up through foursquare then we can get 12000/day for each user.
 
 You can also do multi call just seperate calls with a comma still have to include ll
 You can paginate using offset parameter
 
 For reference of parameters:
 https://developer.foursquare.com/docs/venues/explore
 */

struct VenuesModel: CustomStringConvertible {
    fileprivate var _id: String! //id of the business can be used to get data by business
    fileprivate var _likes:String!
    fileprivate var _name:String! // gives the place name no need to format
    fileprivate var _featuredPhotoURL:URL! // gives featured photo with ability to get different sizes - some can have featured photos
    fileprivate var _photoURL:URL!
    fileprivate var _address:String! // can get formatted address
    fileprivate var _phoneNumber:String! // can get formatted phone number
    fileprivate var _coordinates: (lat:Double,long:Double)
    fileprivate var _rating: String! // based of a 10 rating system - gives a decimal value
    fileprivate var _ratingCount:String! //
    fileprivate var _websiteString:String! // website link for venue
    fileprivate var _placeComment:String! // add messagers name to it
    fileprivate var _reviewerName:String! // name of reviewer
    fileprivate var _priceMessage:String! // not always availale - tells you if it is cheap etc.
    fileprivate var _status:String! // gives 0 or 1 depending on open or not, sometimes gives false or true instead of 0 or 1
    fileprivate var _statusMessage:String! // tells you when it is going to be open next
    fileprivate var _category:String! // gives category such as Breakfast spot - watch out for uniscalars
    fileprivate var _menuURLString:String! // not always available
    fileprivate var _distance: Double! //distance in meters
    fileprivate var _fSqURLString:String! // link back to foursquare website
    fileprivate var _hereNowCount:Int! // how many people are currently there
    fileprivate var _facebookId:String! // can be used later on to link to facebook page
    fileprivate var _currency:String! // currency used at establishment
    fileprivate var _checkInsCount:String! // gives you the number of checkins count
    
    var placeId:String {
        return _id
    }
    var likes:String {
        return _likes
    }
    var name:String {
        return _name
    }
    var placeAddress:String {
        return _address
    }
    var phoneNumber:String {
        return _phoneNumber
    }
    var coordinates: (lat:Double,long:Double) {
        return (_coordinates)
    }
    var rating:String {
        return _rating
    }
    var priceMessage:String {
        return _priceMessage
    }
    var category:String {
        return _category
    }
    var menuURLString: String {
        return _menuURLString
    }
    var distanceMeters:Double {
        return _distance
    }
    var status:String {
        return _status
    }
    var statusMessage:String {
        return _statusMessage
    }
    var reviewerName:String {
        return _reviewerName
    }
    var reviewMessage:String {
        return _placeComment
    }
    var photoURL:URL {
        return _photoURL
    }
    var ratingCount:String {
        return _ratingCount
    }
    var websiteURLString:String {
        return _websiteString
    }
    var fSqURLString:String {
        return _fSqURLString
    }
    var hereNowCount:Int {
        return _hereNowCount
    }
    var facebookId:String {
        return _facebookId
    }
    var currency:String {
        return _currency
    }
    var featuredPhotoURL:URL {
        return _featuredPhotoURL
    }
    var checkInsCount:String {
        return _checkInsCount
    }
    
    // not venue description, rather used
    var description: String {
        return "Name:\(name), placeId: \(placeId), likes: \(likes), Address: \(placeAddress), phoneNumber: \(phoneNumber), coordinates: \(coordinates), rating: \(rating), currency:\(currency), priceMessage: \(priceMessage), category: \(category), menuUrlString: \(menuURLString), distance: \(distanceMeters), status: \(status), statusMessage: \(statusMessage), reviewerName: \(reviewerName), review: \(reviewMessage), photoURL \(photoURL), ratingCount: \(ratingCount), websiteURLString: \(websiteURLString), fsqURLString: \(fSqURLString), hereNowCount: \(hereNowCount), facebookId: \(facebookId), currency: \(currency), featuredPhotoURL: \(featuredPhotoURL), checkInsCount: \(checkInsCount)"
    }
    init(json:JSON) {
        let location = json["venue"]["location"]
        let tips = json["tips"][0]
        let venue = json["venue"]
        let featuredPhotoItems = venue["featuredPhotos"]["items"][0]
        let photoItems = venue["photos"]["groups"][0]["items"][0]
        let price = venue["price"]["tier"].intValue
        
        //Location related json
        
        if let address = location["formattedAddress"].arrayObject as? [String] {
            self._address = address.joined(separator: ",")
        }
        self._coordinates = (location["lat"].doubleValue,location["lng"].doubleValue)
        self._distance = location["distance"].doubleValue
        
        //tips related json
        self._likes = tips["likes"]["count"].stringValue
        self._reviewerName = tips["user"]["firstName"].stringValue
        self._placeComment = tips["text"].stringValue
        self._fSqURLString = tips["canonicalUrl"].stringValue
        
        
        //venue related json
        self._id = venue["id"].stringValue
        self._name = venue["name"].stringValue
        self._category = venue["categories"][0]["name"].stringValue
        self._featuredPhotoURL = checkURL(featuredPhotoItems["prefix"].stringValue + "500X500" + featuredPhotoItems["suffix"].stringValue)
        self._hereNowCount = venue["hereNow"]["count"].intValue
        self._statusMessage = venue["hours"]["status"].stringValue
        self._status = venue["hours"]["isOpen"].intValue > 0 ? "Open": "Closed"
        self._phoneNumber = venue["contact"]["formattedPhone"].stringValue
        self._facebookId = venue["contact"]["facebook"].stringValue
        self._currency = venue["price"]["currency"].stringValue
        
        self._priceMessage = self.getPriceType(price)
        self._photoURL = checkURL(photoItems["prefix"].stringValue + "500x500" + photoItems["suffix"].stringValue)
        self._rating = venue["rating"].stringValue
        self._ratingCount = venue["ratingSignals"].stringValue
        self._websiteString = venue["url"].stringValue
        self._menuURLString = venue["menu"]["url"].stringValue
        self._checkInsCount = venue["stats"]["checkinsCount"].stringValue
    }
    
    fileprivate func getPriceType(_ priceMessage:Int) -> String {
        switch priceMessage {
        case 1:
            return "$"
        case 2:
            return "$$"
        case 3:
            return "$$$"
        case 4:
            return "$$$$"
        default:
            return ""
        }
    }
    
    func checkURL(_ urlString:String) -> URL? {
        guard let url = URL(string: urlString) else {
            return URL(string: "")
        }
        return url
    }
    
}
