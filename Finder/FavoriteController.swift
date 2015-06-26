//
//  FavoriteController.swift
//  Finder
//
//  Created by cmi on 15-06-15.
//  Copyright (c) 2015 0851423. All rights reserved.
//

import UIKit
import CoreData

class FavoriteController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {

    @IBOutlet var picker: UIPickerView!
    @IBOutlet var selectedLabel: UITextField!
    
    var garages:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate

        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Garages")
        
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults {
            garages = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        
        picker.delegate = self
        picker.dataSource = self
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Replace both UITableViewDataSource methods
    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
            return garages.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return garages.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        let g = garages[row];
        
        if let s = g.valueForKey("name") as? String{
            return s
        }else{
            return "error"
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let g = garages[row];
        
        if let s = g.valueForKey("name") as? String{
            self.selectedLabel.text = s
        }else{
            self.selectedLabel.text = "error"
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
