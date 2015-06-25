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
        
        if annotation is User {
            return nil
        }
        
        if annotation is Garage {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            
            pinAnnotationView.pinColor = .Green
            pinAnnotationView.draggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            
            let deleteButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            deleteButton.frame.size.width = 44
            deleteButton.frame.size.height = 44
            deleteButton.backgroundColor = UIColor.greenColor()
            deleteButton.setImage(UIImage(named: "star"), forState: .Normal)
            
            pinAnnotationView.leftCalloutAccessoryView = deleteButton
            
            return pinAnnotationView
        }
        
        
        func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
            if let annotation = view.annotation as? Garage {
                self.mapView.removeAnnotation(annotation)
            }
        }
        
        return nil
    }
}

