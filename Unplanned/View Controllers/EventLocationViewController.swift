//
//  EventLocationViewController.swift
//  Unplanned
//
//  Created by matata on 29.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import CoreLocation

class EventLocationViewController: BaseViewController {

    @IBOutlet weak var labelTitleLocation: UILabel!
    @IBOutlet weak var labelDescriptionLocation: UILabel!
    
    @IBOutlet weak var viewSelectedLocation: UIView!
    @IBOutlet weak var ivLocation: UIImageView!
    
    var currentCoordinates : CLLocationCoordinate2D!
    
    var foursquareId : String!
    
    @IBOutlet weak var btnSelectPlace: UIButton!
    override func viewDidLoad() {
        btnSelectPlace.layer.cornerRadius = 20
        btnSelectPlace.layer.borderWidth = 2
        btnSelectPlace.layer.borderColor = UIColor(rgba: "#00BEE0").CGColor
        
        viewSelectedLocation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventLocationViewController.selectLocationPressed(_:))))
        
        btnSelectPlace.setTitle("Choose a place".localized(), forState: .Normal)
    }
    @IBAction func selectLocationPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("segueSelectLocation", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "segueSelectLocation"{
            let vc = segue.destinationViewController as! LocationSelectViewController
            //vc.colorString = colorLabel.text
            vc.delegate = self
            vc.category = self.foursquareId
        }
    }
}

extension EventLocationViewController : LocationSelectControllerDelegate {
    func myVCDidFinish(text: String, description : String, coordinates : CLLocationCoordinate2D) {
        self.viewSelectedLocation.hidden = false
        self.labelTitleLocation.text = text
        self.labelDescriptionLocation.text = description
        ivLocation.hidden = true
        btnSelectPlace.hidden = true
        self.currentCoordinates = coordinates
    }
}
