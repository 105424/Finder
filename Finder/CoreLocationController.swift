//
//  CoreLocationController.swift
//  Finder
//
//  Created by Hoppinger on 6/25/15.
//  Copyright (c) 2015 0851423. All rights reserved.
//

import UIKit
import CoreLocation

class CoreLocationController: NSObject, CLLocationManagerDelegate {
    
    var locationManager:CLLocationManager = CLLocationManager();
    var loc:CLLocation = CLLocation();
    
    
    override init(){
        super.init();
        self.locationManager.delegate = self;
        self.locationManager.requestAlwaysAuthorization();
    }
   
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            println(".NotDetermined")
            break
            
        case .AuthorizedAlways:
            println(".Authorized")
            self.locationManager.startUpdatingLocation();
            break
            
        case .Denied:
            println(".Denied")
            break
            
        default:
            println("Unhandled authorization status")
            break
            
        }
    }

    func getLocation() -> CLLocation {
        return self.loc;
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        self.loc =  locations.last as CLLocation
        
        println("didUpdateLocations:  \(self.loc.coordinate.latitude), \(self.loc.coordinate.longitude)")
        
    }
}
