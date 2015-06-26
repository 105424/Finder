//
//  MapViewController.swift
//  Finder
//
//  Created by Hoppinger on 6/26/15.
//  Copyright (c) 2015 0851423. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: MKMapView, CLLocationManagerDelegate, MKMapViewDelegate {

    var regionRadius: CLLocationDistance = 100000
    var locationManager:CLLocationManager!
    
    var seenError:Bool = false
    
    override init() {
        super.init();
        
        self.setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    
    func setup(){
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        
        self.delegate = self
        
        var defaults = NSUserDefaults.standardUserDefaults()
        
        if (defaults.objectForKey("mapSize") != nil) {
            self.regionRadius = CLLocationDistance(defaults.integerForKey("mapSize"))
        }
        
        let url = NSURL(string: "http://opendata.technolution.nl/opendata/parkingdata/v1")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            
            println("got data")
            
            var localError: NSError?
            var dic: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &localError)
            
            
            
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
                    
                    self.addAnnotation(garage)
                }
            }
            
        }
        
        task.resume()
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
    
    
    var firstFocus:Bool = true
    func centerMapOnLocation(location: CLLocation) {
        var coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
            regionRadius * 2.0, regionRadius * 2.0)
        
        if(firstFocus){
            self.setRegion(coordinateRegion, animated: false)
            firstFocus = false
        }
        
        
        let user = User(title: "You are here",
            coordinate: location.coordinate)
        
        self.addAnnotation(user)
        
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
            
            var favButton = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
            favButton.frame.size.width = 44
            favButton.frame.size.height = 44
            favButton.backgroundColor = UIColor.greenColor()
            favButton.setImage(UIImage(named: "star"), forState: .Normal)
            
            pinAnnotationView.leftCalloutAccessoryView = favButton
            
            return pinAnnotationView
        }
        
        return nil
    }
        
        func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let annotation = annotationView.annotation as? Garage {
                //1
                let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
                
                let managedContext = appDelegate.managedObjectContext!
                
                let entity =  NSEntityDescription.entityForName("Garages",
                    inManagedObjectContext:
                    managedContext)
                
                let garage = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext:managedContext)
                
                
                let s = annotation.name
                let b = annotation.limitedAccess
                let lat = annotation.lat
                let long = annotation.long
                
                garage.setValue(s, forKey: "name")
                garage.setValue(b, forKey: "limitedAccess")
                garage.setValue(lat, forKey: "lat")
                garage.setValue(long, forKey: "long")
                
                var error: NSError?
                if !managedContext.save(&error) {
                    println("Could not save \(error), \(error?.userInfo)")
                }else{
                    let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                    pinAnnotationView.pinColor = .Purple
                }
            }
        }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
