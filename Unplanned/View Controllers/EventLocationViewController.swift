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
        btnSelectPlace.layer.borderColor = UIColor(rgba: "#00BEE0").cgColor
        
        viewSelectedLocation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventLocationViewController.selectLocationPressed(_:))))
        
        btnSelectPlace.setTitle("Choose a place".localized(), for: UIControlState())
    }
    @IBAction func selectLocationPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueSelectLocation", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "segueSelectLocation"{
            let vc = segue.destination as! LocationSelectViewController
            //vc.colorString = colorLabel.text
            vc.delegate = self
            vc.category = self.foursquareId
        }
    }
}

extension EventLocationViewController : LocationSelectControllerDelegate {
    func myVCDidFinish(_ text: String, description : String, coordinates : CLLocationCoordinate2D) {
        self.viewSelectedLocation.isHidden = false
        self.labelTitleLocation.text = text
        self.labelDescriptionLocation.text = description
        ivLocation.isHidden = true
        btnSelectPlace.isHidden = true
        self.currentCoordinates = coordinates
    }
}
