//
//  MapAnnotation.swift
//  Unplanned
//
//  Created by matata on 06.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import MapKit

class CoffeeAnnotation: NSObject, MKAnnotation
{
    let title:String?;
    let subtitle:String?;
    let coordinate: CLLocationCoordinate2D;
    
    init(title: String?, subtitle:String?, coordinate: CLLocationCoordinate2D)
    {
        self.title = title;
        self.subtitle = subtitle;
        self.coordinate = coordinate;
        
        super.init();
    }
}
