//
//  LocationSelectViewController.swift
//  Unplanned
//
//  Created by matata on 29.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import MapKit
import RealmSwift

protocol LocationSelectControllerDelegate{
    func myVCDidFinish(_ text:String, description: String, coordinates : CLLocationCoordinate2D)
}

class LocationSelectViewController: BaseViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    
    var delegate:LocationSelectControllerDelegate?
    var category : String!
    
    let categoryArr = ["Arts_&_Entertainment","Food","Nightlife_Spot","Outdoors_&_Recreation"]
    
    let fSqClient = Client.instance
    
    var currentCoodinates : CLLocationCoordinate2D!
    
    
    var venueList = [VenuesModel]()
    
    var updatedData = false
    
    
    var filteredList = [VenuesModel]()
    
    @IBOutlet weak var ivClearText: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tfSearch: UITextField!
    /// Location manager to get the user's location
    var locationManager:CLLocationManager?
    
    var lastLocation:CLLocation?
    let distanceSpan:Double = 500
    
    override func viewDidLoad() {
        //self.tableView.contentInset = UIEdgeInsets(top: -60,left: 0,bottom: 0,right: 0)
        tfSearch.addTarget(self, action: #selector(LocationSelectViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.tfSearch.delegate = self
        self.tfSearch.placeholder = "Search Place".localized()
       // self.hideKeyboardWhenTappedAround()
    }
    
    
    func updateData() {
        
        hudShow()
        if self.tfSearch.text?.isEmpty == false {
            fSqClient.searchWithTerm(self.tfSearch.text!, ll: ((lastLocation?.coordinate.latitude)!, (lastLocation?.coordinate.longitude)!), offset: 0, open: .all) {
                (venues) in

                self.venueList = venues
                self.filteredList = venues

                DispatchQueue.main.async(execute: {
                    self.updatedData = true
                    self.locationManager?.stopUpdatingLocation()
                    self.tableView.reloadData()
                    self.hudHide()
                })
            }
        } else {
            fSqClient.searchWithCategory(category, ll: ((lastLocation?.coordinate.latitude)!, (lastLocation?.coordinate.longitude)!), offset: 0, open: .all) {
                (venues) in

                self.venueList = venues
                self.filteredList = venues

                DispatchQueue.main.async(execute: {
                    self.updatedData = true
                    self.locationManager?.stopUpdatingLocation()
                    self.tableView.reloadData()
                    self.hudHide()
                })
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.tfSearch.resignFirstResponder()
        view.endEditing(true);
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if !(textField.text?.isEmpty)! {
            ivClearText.isHidden = false
            
//            self.filteredList = venueList.filter({
//                $0.name.lowercaseString.containsString(textField.text!.lowercaseString)
//                })
        }
        else {
//            self.filteredList = self.venueList
            ivClearText.isHidden = true
        }

        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(LocationSelectViewController.updateData), with: nil, afterDelay: 0.5)

//        self.tableView.reloadData()
    }

    @IBAction func clearText(_ sender: AnyObject) {
        self.tfSearch.text = ""
        ivClearText.isHidden = true
         self.filteredList = self.venueList
        self.tableView.reloadData()
    }
    
    func refreshVenues(_ location: CLLocation?, getDataFromFoursquare:Bool = false)
    {
        if updatedData {
            return
        }
        
        // If location isn't nil, set it as the last location
        if location != nil
        {
            lastLocation = location
        }
        if let location = lastLocation
        {
            // Make a call to Foursquare to get data
            if getDataFromFoursquare == true
            {
                self.updateData()
            }
        }
    }
    
    func calculateCoordinatesWithRegion(_ location:CLLocation) -> (CLLocationCoordinate2D, CLLocationCoordinate2D)
    {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, distanceSpan, distanceSpan)
        
        var start:CLLocationCoordinate2D = CLLocationCoordinate2D()
        var stop:CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        start.latitude  = region.center.latitude  + (region.span.latitudeDelta  / 2.0)
        start.longitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
        stop.latitude   = region.center.latitude  - (region.span.latitudeDelta  / 2.0)
        stop.longitude  = region.center.longitude + (region.span.longitudeDelta / 2.0)
        
        return (start, stop)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated);
        self.setupGradienNavigationBar("Create Event".localized())
        self.createNavigationBarButtons()
       
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        if locationManager == nil
        {
            locationManager = CLLocationManager()
            
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager!.requestAlwaysAuthorization()
            locationManager!.distanceFilter = 50 // Don't send location updates with a distance smaller than 50 meters between them
            locationManager!.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation)
    {
            // When a new location update comes in, reload from Realm and from Foursquare
            refreshVenues(newLocation, getDataFromFoursquare: true);
    }
    
    func onVenuesUpdated(_ notification:Foundation.Notification)
    {
        // When new data from Foursquare comes in, reload from local Realm
        refreshVenues(nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (section == 0) {
            return 1;
        }
        // When venues is nil, this will return 0 (nil-coalescing operator ??)
        return filteredList.count ?? 0
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        if lastLocation == nil {
            return 0
        }

        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlacesTableViewCell") as! PlacesTableViewCell

        if (indexPath.section == 0) {
            cell.titleLabel?.text = "My location"
            cell.titleLabelTopConstraint.constant = 25
            cell.descriptionLabel?.text = ""
            cell.ivIsActive.isHidden = true
            cell.descriptionLabel.tag = indexPath.row
        }
        else {
            let venue = filteredList[indexPath.row]

            cell.titleLabel?.text = venue.name
            cell.titleLabelTopConstraint.constant = 0
            cell.descriptionLabel?.text = venue.placeAddress
            cell.ivIsActive.isHidden = true
            cell.descriptionLabel.tag = indexPath.row
//            cell.descriptionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LocationSelectViewController.openMap(_:))))
        }
        return cell;
    }
    
    func openMap(_ sender : UITapGestureRecognizer) {
        let touch = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touch) {
            // Access the image or the cell at this index path
            performSegue(withIdentifier: "segueOpenMap", sender: indexPath.row)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueOpenMap" {
            let destinationVC = segue.destination as! MapViewController
            
            destinationVC.titleLocation = self.filteredList[sender as! Int].name
            destinationVC.addressLocation = self.filteredList[sender as! Int].placeAddress
            destinationVC.addressLong = self.filteredList[sender as! Int].coordinates.long
            destinationVC.adressLat = self.filteredList[sender as! Int].coordinates.lat
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {

        self.view.endEditing(true)
        tableView.reloadData()

        let cell = tableView.cellForRow(at: indexPath) as! PlacesTableViewCell
        cell.ivIsActive.isHidden = false

        if (indexPath.section == 0) {
            self.delegate?.myVCDidFinish("My location", description: "", coordinates: lastLocation!.coordinate)
        } else {
            self.delegate?.myVCDidFinish((filteredList[indexPath.row].name), description: (filteredList[indexPath.row].placeAddress), coordinates: CLLocationCoordinate2D(latitude: filteredList[indexPath.row].coordinates.lat, longitude: filteredList[indexPath.row].coordinates.long))
        }

        self.navigationController?.popViewController(animated: true)

    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    func createNavigationBarButtons(){
        var menuImage:UIImage = UIImage(named: "icon_close_event")!
        
        menuImage = menuImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let menuButton: UIButton = UIButton(frame: CGRect(x: 20, y: 20, width: 25, height: 25))
        menuButton.setImage(menuImage, for: UIControlState())
        menuButton.setImage(menuImage, for: .highlighted)
        menuButton.addTarget(self, action: #selector(CreateEventViewController.close(_:)), for:.touchUpInside)
        let menuButtonBar = UIBarButtonItem.init(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuButtonBar
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateEventViewController.submit(_:)))
    }
    
    func close(_ sender: UIButton) {
        self.setTransparentNavigationBar()
        self.navigationController?.popViewController(animated: true)
    }
    
    func submit(_ sender : UIButton) {
        self.setTransparentNavigationBar()
        self.navigationController?.popViewController(animated: true)
    }
}

extension RangeReplaceableCollection where Iterator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
