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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interfaceSetup()
    }
    
    func interfaceSetup() {
    }
    
    func createTimestamp() -> String {
        // Date in format: "2018-06-25 09:04"
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: now)
        return dateString
    }
}
