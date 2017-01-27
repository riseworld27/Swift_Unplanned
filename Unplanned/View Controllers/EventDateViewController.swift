//
//  EventDateViewController.swift
//  Unplanned
//
//  Created by matata on 29.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import SwiftDate

class EventDateViewController: BaseViewController {

    
    @IBOutlet weak var labelTitleDate: UILabel!
    @IBOutlet weak var labelTitleTime: UILabel!
    
    @IBOutlet weak var viewDate: UIView!
    @IBOutlet weak var ivDate: UIImageView!
    
    var selectedDate : NSDate!
    
    
    @IBOutlet weak var btnSelectDate: UIButton!
    override func viewDidLoad() {
        btnSelectDate.layer.cornerRadius = 20
        btnSelectDate.layer.borderWidth = 2
        btnSelectDate.layer.borderColor = UIColor(rgba: "#00BEE0").CGColor
        
        viewDate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventDateViewController.selectDatePressed(_:))))
        btnSelectDate.setTitle("Choose a date and time".localized(), forState: .Normal)
    }
    @IBAction func selectDatePressed(sender: AnyObject) {
        
        let datePicker = ActionSheetDatePicker(title: "Date and time".localized(), datePickerMode: UIDatePickerMode.DateAndTime, selectedDate: NSDate(), doneBlock: {
            picker, value, index in
            
            print("value = \(value)")
            print("index = \(index)")
            print("picker = \(picker)")
            
            self.selectedDate = value as! NSDate
            
            let year = NSString(string: String(self.selectedDate.year)).substringFromIndex(2)
            self.labelTitleDate.text = "\(self.selectedDate.monthName.capitalizedString) \(self.selectedDate.day) '\(year)"
            self.labelTitleTime.text = "\(self.selectedDate.mt_stringFromDateWithShortWeekdayTitle()) - \((self.timeFormat(self.selectedDate)).lowercaseString)"
            self.viewDate.hidden = false
            self.btnSelectDate.hidden = true
            self.ivDate.hidden = true
            return
            },cancelBlock: { ActionStringCancelBlock in return
            },
              origin: view.superview!.superview)
        //let secondsInWeek: NSTimeInterval = 7 * 24 * 60 * 60;
        //datePicker.minimumDate = NSDate(timeInterval: -secondsInWeek, sinceDate: NSDate())
        //datePicker.maximumDate = NSDate(timeInterval: secondsInWeek, sinceDate: NSDate())
        
        datePicker.showActionSheetPicker()
        
        
    }
}
