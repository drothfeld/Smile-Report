//
//  NewDayEntryViewController.swift
//  Smile Report
//
//  Created by Dylan Rothfeld on 6/25/18.
//  Copyright © 2018 Dylan Rothfeld. All rights reserved.
//

import UIKit
import AVFoundation

class NewDayEntryViewController: UIViewController {
    // Storyboard Outlets
    
    // Controller Values
    var chosenSmile: Smile! = nil
    var dayEntryData: [DayEntry] = mockData
    
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
        let dayEntry: DayEntry = DayEntry(timestamp: timestamp, smileEntryIndex: chosenSmile!.value!)
        
        // TODO:
        // Save dayEntry object into main data stream
        loadSmileData(dayEntry: dayEntry)
        
        // Segue to CompletedDataEntryViewController, passing the chosen smile
        AudioServicesPlaySystemSound(SystemSoundID(1022))
        performSegue(withIdentifier: "toCompletedDataEntry", sender: self)
    }
    
    // Load userDefaults smile data
    func loadSmileData(dayEntry: DayEntry) {
        if let data = UserDefaults.standard.data(forKey: "dayEntryData"),
            // Attempt to load data from userDefaults
            let savedDayEntryData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [DayEntry] {
                dayEntryData = savedDayEntryData
                dayEntryData.append(dayEntry)
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: dayEntryData)
                UserDefaults.standard.set(encodedData, forKey: "dayEntryData")
        } else {
            // If there is no saved data, then create new userDefaults saved data
            var newData: [DayEntry] = []
            newData.append(dayEntry)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: newData)
            UserDefaults.standard.set(encodedData, forKey: "dayEntryData")
        }
    }
}
