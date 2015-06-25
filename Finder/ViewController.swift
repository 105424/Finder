//
//  ViewController.swift
//  Finder
//
//  Created by cmi on 15-06-15.
//  Copyright (c) 2015 0851423. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet var mapView: MKMapView!
    var locationManager:CLLocationManager!
    
    var seenError : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        
        let url = NSURL(string: "http://opendata.technolution.nl/opendata/parkingdata/v1")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            //println(NSString(data: data, encoding: NSUTF8StringEncoding))
        }
        
        task.resume()
        
    //    let initialLocation = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
    //    centerMapOnLocation(initialLocation)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if ((error) != nil) {
            if (self.seenError == false) {
                self.seenError = true
                print(error)
            }
        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let loc =  locations.last as CLLocation
        
        centerMapOnLocation(loc)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        println("didChangeAuthorizationStatus")
        
        switch status {
        case .NotDetermined:
            println(".NotDetermined")
            break
            
        case .AuthorizedWhenInUse:
            println("When in use Authorized")
            self.locationManager.startUpdatingLocation();
            break
        
        case .AuthorizedAlways:
            println("Always Authorized")
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var firstFocus:Bool = true
    let regionRadius: CLLocationDistance = 10000
    func centerMapOnLocation(location: CLLocation) {
        var coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        
        if(firstFocus){
            mapView.setRegion(coordinateRegion, animated: true)
            firstFocus = false
        }
        
        
        let user = User(title: "You are here",
            coordinate: location.coordinate)
        
        mapView.addAnnotation(user)
        
    }
}

