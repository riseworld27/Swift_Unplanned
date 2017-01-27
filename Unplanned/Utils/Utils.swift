//
//  Utils.swift
//  Unplanned
//
//  Created by True Metal on 5/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import UIAlertControllerExtension
import MBProgressHUD

typealias VoidBlock = ()->()
func after(delay:Double, block:VoidBlock) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (Int64)(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}

extension NSObject {    
    class var className:String { get { return NSStringFromClass(self).componentsSeparatedByString(".").last ?? "---ERROR can't get className---" } }
}

// MARK: uimsg

func appName() -> String {
    return NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? "N/A"
}

func UIMsg(msg:String) {
    UIAlertController.present(title: appName(), message: msg, actionTitles: ["Ok"])
}

// MARK: hud

func hudShow(view:UIView) {
    MBProgressHUD.showHUDAddedTo(view, animated: true)
}

func hudHide(view:UIView) {
    MBProgressHUD.hideAllHUDsForView(view, animated: true)
}

