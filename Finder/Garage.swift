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
    let coordinate: CLLocationCoordinate2D
    let limitedAccess: Bool
    
    init(title: String, coordinate: CLLocationCoordinate2D, limitedAcces: Bool) {
        self.title = title
        self.coordinate = coordinate
        self.limitedAccess = limitedAcces
        
        super.init()
    }
    
    var subtitle: String {
        if(limitedAccess){
            return "Gelimiteerde toegang"
        }else{
            return ""
        }
    }
}
