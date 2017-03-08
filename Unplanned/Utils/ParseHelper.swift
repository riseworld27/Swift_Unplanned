//
//  ParseHelper.swift
//  Unplanned
//
//  Created by matata on 04.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import Parse

func clearRelation(_ user: PFUser, relationName: String) {
    let relation = user.relation(forKey: relationName)
    let query = relation.query()
    
    query.findObjectsInBackground(block: {(objects, error) -> Void in
        if error == nil {
            for item in objects! {
                relation.remove(item )
            }
            
            user.saveInBackground()
        }
    })
}

func registerPFUserForPushNotifications(_ user:PFUser){
    let installation = PFInstallation.current()
    installation["user"] = user
    installation["username"] = user.username
    installation.saveInBackground()
    
}

func updateBadges() {
    let installation = PFInstallation.current()
    installation["badge"] = 0
    installation.badge = 0
    installation.saveInBackground()
}

func subscribeUserToPushNotificationChannel(_ channelName:String){
    let currentInstallation = PFInstallation.current()
    currentInstallation.remove(channelName, forKey: "channels")
    currentInstallation.saveInBackground()
}

func sendPushNotificationToUser(_ recipientId:String, title:String, message:String, pushType:String){
    
    let data = [ "alert": ["title" : title, "body" : message],
                 "badge" : "Increment",
                 "title" : title] as [String : Any]
    
    let query: PFQuery = PFInstallation.query()!
    
    
    query.whereKey("username", equalTo: recipientId)
    
    let push: PFPush = PFPush()
    push.setQuery(query)
    push.setData(data as [AnyHashable: Any])
    push.sendInBackground { (done: Bool, error: NSError?) in
        if error == nil {
            print ("sent to \(recipientId)")
        }
    }
    
    
//    var deviceQuery = PFInstallation.query()
//    deviceQuery.whereKey("userId", equalTo: user.objectId)
//    
//    var push1 = PFPush()
//    push1.setMessage(messageField.text)
//    push1.setMessage("You've been invited to a match")
//    push1.setQuery(deviceQuery)
//    push1.sendPush(nil)
    
    
}

func sendPushNotificationToChannel(_ channelName:String, message:String){
    let push = PFPush()
    push.setChannel(channelName)
    push.setMessage(message)
    push.sendInBackground()
}

func getPFUser(_ username:String, completion:@escaping (_ foundUser:PFUser) -> Void){
    let usernameQuery = PFQuery(className: "_User")
    usernameQuery.whereKey("username", equalTo: username)
    
    let fbNameQuery = PFQuery(className: "_User")
    fbNameQuery.whereKey("fbName", equalTo: username)
    
    var foundPFUser:PFUser?
    
    let query = PFQuery.orQuery(withSubqueries: [fbNameQuery, usernameQuery])
    query.findObjectsInBackground(block: {(object, error) -> Void in
        if error == nil && object?.count == 1{
            for item in object! {
                foundPFUser = item as? PFUser
            }
        }
        completion(foundPFUser!)
    })
    
}
