//
//  NewDayEntryViewController.swift
//  Smile Report
//
//  Created by Dylan Rothfeld on 6/25/18.
//  Copyright © 2018 Dylan Rothfeld. All rights reserved.
//

import UIKit

class NewDayEntryViewController: UIViewController {
    // Storyboard Outlets
    
    // Controller Values
    var chosenSmile: Smile! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interfaceSetup()
    }
    
    // Change any interface settings
    func interfaceSetup() {
    }
    
    // Create timestamp as string
    func createTimestamp() -> String {
        // Date in format: "2018-06-25 09:04"
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: now)
        return dateString
    }
    
    // Prepare segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toCompletedDataEntry" {
            let controller = segue.destination as! CompletedDataEntryViewController
            controller.chosenSmile = chosenSmile
        }
    }
    
    // User presses a smile button
    @IBAction func emotionButtonPressed(sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        // Create dayEntry object and values
        chosenSmile = smiles[button.tag]
        let timestamp: String = createTimestamp()
        let dayEntry: DayEntry = DayEntry(timestamp: timestamp, smileEntry: chosenSmile!)
        
        // TODO:
        // Save dayEntry object into main data stream
        
        
        // Segue to CompletedDataEntryViewController, passing the chosen smile
        performSegue(withIdentifier: "toCompletedDataEntry", sender: self)
        
    }
}
