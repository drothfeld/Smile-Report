//
//  HomeViewController.swift
//  Smile Report
//
//  Created by Dylan Rothfeld on 6/19/18.
//  Copyright © 2018 Dylan Rothfeld. All rights reserved.
//

import UIKit
import UserNotifications

class HomeViewController: UIViewController {
    // Storyboard Outlets
    @IBOutlet weak var PageControl: UIPageControl!
    @IBOutlet weak var GraphScrollView: UIScrollView!
    @IBOutlet weak var CurrentWeekdayNameLabel: UILabel!
    @IBOutlet weak var CurrentDateLabel: UILabel!
    @IBOutlet weak var PositiveDaysValueLabel: UILabel!
    @IBOutlet weak var TotalDataPointsValueLabel: UILabel!
    @IBOutlet weak var StatusMessageLabel: UILabel!
    
    // Controller Values
    var dayEntryData: [DayEntry] = mockData
    var dataPointEnteredToday: Bool = false // This needs to pull its value from somewhere, probably userdefaults

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
        setStatusMessage()
        dailyNotificationRequester()
    }
    
    // Daily notification requester
    func dailyNotificationRequester() {
        // timeInterval is in seconds, so 60*60*12*3 = 3 days, set repeats to true if you want to repeat the trigger
        let requestTrigger = UNTimeIntervalNotificationTrigger(timeInterval: (60*60*12*1), repeats: true)
        
        let requestContent = UNMutableNotificationContent()
        requestContent.title = "Daily Entry"
        //requestContent.subtitle = "Subtitle"
        requestContent.body = "How is your day going? Don't forget to input your smile entry for the day!"
        requestContent.badge = 1
        requestContent.sound = UNNotificationSound.default()
        
        // Request the notification
        let request = UNNotificationRequest(identifier: "Smile Report", content: requestContent, trigger: requestTrigger)
            
            // Post the notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    NSLog(error as! String)
                } else {
                    // posted successfully, do something like tell the user that notification was posted
                }
            }
    }
    
    // Sets the status message based on the current entry state for the day
    func setStatusMessage() {
        if (dataPointEnteredToday) {
            StatusMessageLabel.text = "Completed Daily Entry"
        } else {
            StatusMessageLabel.text = "Missing Daily Entry"
        }
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

