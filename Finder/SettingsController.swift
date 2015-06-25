//
//  SettingsController.swift
//  Finder
//
//  Created by Hoppinger on 6/25/15.
//  Copyright (c) 2015 0851423. All rights reserved.
//

import UIKit

class SettingsController: UIViewController {

    @IBOutlet var size: UISlider!
    @IBOutlet var sizeText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var defaults = NSUserDefaults.standardUserDefaults()
        
        var val = Int(size.value)
        if (defaults.objectForKey("mapSize") != nil) {
            val = defaults.integerForKey("mapSize")
            size.value = Float(val)
        }
        
        sizeText.text = "\(val)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sliderValueChanged(sender: UISlider) {
        
        var defaults = NSUserDefaults.standardUserDefaults()
        
        let val = Int(size.value)
        sizeText.text = "\(val)"
        
        defaults.setInteger(val, forKey: "mapSize")
        
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
