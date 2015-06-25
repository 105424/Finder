//
//  Garage.swift
//  Finder
//
//  Created by Hoppinger on 6/25/15.
//  Copyright (c) 2015 0851423. All rights reserved.
//

import UIKit
import MapKit

class Garage: NSObject, MKAnnotation {
    let title: String
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String {
        return locationName
    }
}
