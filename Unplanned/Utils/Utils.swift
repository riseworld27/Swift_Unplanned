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
func after(_ delay:Double, block:@escaping VoidBlock) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double((Int64)(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
}

extension NSObject {    
    class var className:String { get { return NSStringFromClass(self).components(separatedBy: ".").last ?? "---ERROR can't get className---" } }
}

// MARK: uimsg

func appName() -> String {
    return Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "N/A"
}

func UIMsg(_ msg:String) {
    UIAlertController.present(title: appName(), message: msg, actionTitles: ["Ok"])
}

// MARK: hud

func hudShow(_ view:UIView) {
    MBProgressHUD.showAdded(to: view, animated: true)
}

func hudHide(_ view:UIView) {
    MBProgressHUD.hideAllHUDs(for: view, animated: true)
}

