//
//  HomeViewController.swift
//  Smile Report
//
//  Created by Dylan Rothfeld on 6/19/18.
//  Copyright © 2018 Dylan Rothfeld. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    // Storyboard Outlets
    @IBOutlet weak var PageControl: UIPageControl!
    @IBOutlet weak var GraphScrollView: UIScrollView!
    @IBOutlet weak var CurrentWeekdayNameLabel: UILabel!
    @IBOutlet weak var CurrentDateLabel: UILabel!
    @IBOutlet weak var PositiveDaysValueLabel: UILabel!
    @IBOutlet weak var TotalDataPointsValueLabel: UILabel!
    
    // Controller Values
    var dayEntryData: [DayEntry] = mockData

    override func viewDidLoad() {
        super.viewDidLoad()
        interfaceSetup()
    }
    
    func interfaceSetup() {
        // Changing status bar to white text
        UIApplication.shared.statusBarStyle = .lightContent
        // Update summary panels
        setDate()
        setDataStatistics()
    }
    
    // Sets the positive days and total entries entered panel cards
    func setDataStatistics() {
        var totalEntries: Double = 0.00
        var positiveEntries: Double = 0.00
        // Check for positive days days
        for dataEntry in dayEntryData {
            totalEntries += 1.00
            if (dataEntry.smileEntry.value == smile_happy.value || dataEntry.smileEntry.value == smile_love.value || dataEntry.smileEntry.value == smile_excitement.value) {
                positiveEntries += 1.00
            }
        }
        let percentageHappy: Int = Int((positiveEntries/totalEntries) * 100)
        // Change label values
        if percentageHappy < 10 {
            PositiveDaysValueLabel.text = "0" + String(percentageHappy) + "%"
        } else {
            PositiveDaysValueLabel.text = String(percentageHappy) + "%"
        }
        TotalDataPointsValueLabel.text = String(Int(totalEntries))
    }
    
    // Sets the current date panel to the actual current date
    func setDate() {
        // Getting date information
        let currentDateTime = Date()
        let userCalendar = Calendar.current
        let requestedComponents: Set<Calendar.Component> = [
            .year,
            .month,
            .day,
            .hour,
            .minute,
            .second,
        ]
        let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
        let currentYear = String(dateTimeComponents.year!) // 2018
        let currentMonth = String(dateTimeComponents.month!) // 7
        let currentDay = String(dateTimeComponents.day!) // 1
        let formatter = DateFormatter()
        let currentWeekday = String(formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1])
        // Setting outlet values
        CurrentWeekdayNameLabel.text = currentWeekday
        CurrentDateLabel.text = currentMonth + "/" + currentDay + "/" + currentYear
    }
    
    // userDefaults custom data type storage: https:\\stackoverflow.com/questions/37980432/swift-3-saving-and-retrieving-custom-object-from-userdefaults
    // Hooking up page control with scroll view: https:\\www.youtube.com/watch?v=X2Wr4TtMG6Q

}

