//
//  Client.swift
//  Unplanned
//
//  Created by matata on 02.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import SwiftyJSON


class Client {
    
    
    static let instance = Client()
    fileprivate init () {}
    func searchWithTerm(_ term:String,ll:(lat:Double, long:Double), offset:Int, open:OpenType,completion:@escaping FSqData) -> () {
        
        let urlString = "\(URL_BASE)\(URL_EXPLORE)ll=\(ll.lat),\(ll.long)&venuePhotos=1&client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&limit=50&open=\(open.rawValue)&query=\(term)&offset=\(offset)&v=\(API_VERSION)"
        
        getDataWithSession(urlString) { (venues) in
            completion(venues)
        }
    }
    
    func searchWithCategory(_ category:String,ll:(lat:Double,long:Double), offset:Int, open:OpenType, completion: @escaping FSqData) -> ()  {
        let urlString = "\(URL_BASE)\(URL_EXPLORE)ll=\(ll.lat),\(ll.long)&venuePhotos=1&client_id=\(CLIENT_ID)&client_secret=\(CLIENT_SECRET)&limit=50&open=\(open.rawValue)&offset=\(offset)&v=\(API_VERSION)&query=\(category)"
        
        
        getDataWithSession(urlString, completion: { (venues) in
            completion(venues)
        })
        
    }
    
    fileprivate func getVenuesWithJSON(_ data:Data?) -> [VenuesModel] {
        if  let metaData = data {
            
            let jsonData = JSON(data: metaData)
            var venueArray = [VenuesModel]()
            for data in jsonData["response"]["groups"][0]["items"] {
                
                let venue = VenuesModel(json: data.1)
                venueArray.append(venue)
            }
            return venueArray
        } else {
            return [VenuesModel]()
        }
    }
    
    fileprivate func getDataWithSession(_ urlString:String,completion:@escaping FSqData) -> () {
        if let url = checkURL(urlString) {
            let session = URLSession.shared
            session.dataTask(with: url, completionHandler: { (data, response, error) in
                if error == nil {
                    let venues = self.getVenuesWithJSON(data)
                    completion(venues)
                } else {
                    print(error)
                }
                }) .resume()
        }
    }
    
}
