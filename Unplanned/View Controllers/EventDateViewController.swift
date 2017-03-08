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
    
    var selectedDate : Date!
    
    
    @IBOutlet weak var btnSelectDate: UIButton!
    override func viewDidLoad() {
        btnSelectDate.layer.cornerRadius = 20
        btnSelectDate.layer.borderWidth = 2
        btnSelectDate.layer.borderColor = UIColor(rgba: "#00BEE0").cgColor
        
        viewDate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventDateViewController.selectDatePressed(_:))))
        btnSelectDate.setTitle("Choose a date and time".localized(), for: UIControlState())
    }
    @IBAction func selectDatePressed(_ sender: AnyObject) {
        
        let datePicker = ActionSheetDatePicker(title: "Date and time".localized(), datePickerMode: UIDatePickerMode.dateAndTime, selectedDate: Date(), doneBlock: {
            picker, value, index in
            
            print("value = \(value)")
            print("index = \(index)")
            print("picker = \(picker)")
            
            self.selectedDate = value as! Date
            
            let year = NSString(string: String(self.selectedDate.year)).substring(from: 2)
            self.labelTitleDate.text = "\(self.selectedDate.monthName.capitalized) \(self.selectedDate.day) '\(year)"
            self.labelTitleTime.text = "\(self.selectedDate.mt_stringFromDateWithShortWeekdayTitle()) - \((self.timeFormat(self.selectedDate)).lowercased())"
            self.viewDate.isHidden = false
            self.btnSelectDate.isHidden = true
            self.ivDate.isHidden = true
            return
            },cancel: { ActionStringCancelBlock in return
            },
              origin: view.superview!.superview)
        //let secondsInWeek: NSTimeInterval = 7 * 24 * 60 * 60;
        //datePicker.minimumDate = NSDate(timeInterval: -secondsInWeek, sinceDate: NSDate())
        //datePicker.maximumDate = NSDate(timeInterval: secondsInWeek, sinceDate: NSDate())
        
        datePicker.show()
        
        
    }
}
