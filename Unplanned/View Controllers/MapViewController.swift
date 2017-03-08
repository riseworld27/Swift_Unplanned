//
//  MapViewController.swift
//  Unplanned
//
//  Created by matata on 06.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import MapKit

class MapViewController : BaseViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    var currentLocation : CLLocation!
    
    var didFindMyLocation = false
    
    
    var titleLocation : String! = ""
    var addressLocation : String! = ""
    var adressLat : Double! = 0
    var addressLong : Double! = 0
    
    var flatCoordinates : CLLocationCoordinate2D!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGradienNavigationBar("Map")
        self.createNavigationBarButtons()
        
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.requestAlwaysAuthorization();
        locationManager.distanceFilter = 50; // Don't send location updates with a distance smaller than 50 meters between them
        locationManager.startUpdatingLocation();
        self.mapView.delegate = self
        
        
        if titleLocation != nil {
            let annotation = CoffeeAnnotation(title: titleLocation, subtitle: addressLocation, coordinate: CLLocationCoordinate2D(latitude: adressLat, longitude: addressLong))
             mapView?.addAnnotation(annotation);
            
            
            let span = MKCoordinateSpanMake(0.08, 0.08)
            
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: adressLat, longitude: addressLong), span: span)
            
            
            mapView?.setRegion(region, animated: true);
            
            
        }
        
        self.mapView.addObserver(self, forKeyPath: "myLocation", options: .new, context: nil)
    }
    
    func createNavigationBarButtons(){
        var menuImage:UIImage = UIImage(named: "icon_back_button")!
        
        menuImage = menuImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let menuButton: UIButton = UIButton(frame: CGRect(x: 20, y: 20, width: 25, height: 25))
        menuButton.setImage(menuImage, for: UIControlState())
        menuButton.setImage(menuImage, for: .highlighted)
        menuButton.addTarget(self, action: #selector(CreateEventViewController.close(_:)), for:.touchUpInside)
        let menuButtonBar = UIBarButtonItem.init(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuButtonBar
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if annotation.isKind(of: MKUserLocation.self)
        {
            return nil;
        }
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationIdentifier");
        
        if view == nil
        {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationIdentifier");
        }
        
        view?.canShowCallout = true;
        
        return view;
    }
    
    
    func close(_ sender: UIButton) {
        self.setTransparentNavigationBar()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.authorizedWhenInUse {
            mapView.showsUserLocation = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let span = MKCoordinateSpanMake(0.075, 0.075)
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: span)
        
        //self.mapView.setRegion(region, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager.stopUpdatingLocation()
        self.mapView.removeObserver(self, forKeyPath: "myLocation")
    }
    
}
