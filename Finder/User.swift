//
//  User.swift
//  Finder
//
//  Created by Hoppinger on 6/25/15.
//  Copyright (c) 2015 0851423. All rights reserved.
//

import UIKit
import MapKit

class User: NSObject, MKAnnotation {
    var title: String
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
    
    var subtitle: String {
        return ""
    }
}
