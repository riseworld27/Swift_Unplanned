//
//  Constants.swift
//  Unplanned
//
//  Created by matata on 02.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation

typealias FSqData = ([VenuesModel]) -> ()

let URL_BASE = "https://api.foursquare.com/v2/"
let URL_EXPLORE = "venues/explore?"
let CLIENT_SECRET = "1TWCXHPUKQIQBIWBO0FMR1KJRYQ104RQQGWUSE1TUZBO5AA3"
let CLIENT_ID = "OU5WFUWUI5YASOAMULYH5KEUMSWV1IAHKFAOAABR5RXPM52Q"
let API_VERSION = "20160415"

enum OpenType:Int {
    case all = 0
    case openOnly
}

func checkURL(_ urlString:String) -> URL? {
    guard let url = URL(string: urlString) else {
        return URL(string: "")
    }
    return url
}
