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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate{

    @IBOutlet var mapView: MKMapView!
    var locationManager:CLLocationManager!
    var seenError : Bool = false
    var regionRadius: CLLocationDistance = 100000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        
        var defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("mapSize") != nil) {
            self.regionRadius = CLLocationDistance(defaults.integerForKey("mapSize"))
        }
        
        self.mapView.delegate = self
        
        let url = NSURL(string: "http://opendata.technolution.nl/opendata/parkingdata/v1")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            
            println("got data")
            
            var dic = self.parseJSON(data);
        
            let garages = dic.valueForKey("parkingFacilities") as? NSArray
            
            for gar : AnyObject in garages! {
                if let gar = gar as? NSDictionary {
                    
                    let title = gar.valueForKey("name") as? NSString
                    
                    let loc = gar.valueForKey("locationForDisplay") as? NSDictionary
                    let lat = loc?.valueForKey("latitude") as? Double
                    let long = loc?.valueForKey("longitude") as? Double
    
                    let limitedAcces = gar.valueForKey("limitedAccess") as? Bool
                    
                    var garage = Garage(
                        title: title!,
                        coordinate: CLLocationCoordinate2D(
                            latitude: lat!,
                            longitude: long!
                        ),
                        limitedAcces: limitedAcces!)
                    
                    self.mapView.addAnnotation(garage)
                }
            }
            
        }
        
        task.resume()
    }
    
    func parseJSON(inputData: NSData) -> NSDictionary{
        var error: NSError?
        var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
        
        return boardsDictionary
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
    func centerMapOnLocation(location: CLLocation) {
        var coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        
        if(firstFocus){
            mapView.setRegion(coordinateRegion, animated: false)
            firstFocus = false
        }
        
        
        let user = User(title: "You are here",
            coordinate: location.coordinate)
        
        mapView.addAnnotation(user)
        
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = annotation as? User {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView {
                    dequeuedView.annotation = annotation
                    view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
                view.pinColor = .Green
            }
            return view
        }
        return nil
    }
}

