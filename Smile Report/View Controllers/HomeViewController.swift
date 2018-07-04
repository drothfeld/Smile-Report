//
//  HomeViewController.swift
//  Smile Report
//
//  Created by Dylan Rothfeld on 6/19/18.
//  Copyright © 2018 Dylan Rothfeld. All rights reserved.
//

import UIKit
import UserNotifications
import Charts

class HomeViewController: UIViewController, UIScrollViewDelegate {
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
    var frame = CGRect(x:0, y:0, width: 0, height: 0)
    let numberOfGraphs = 3
    var currentMonthValue: String!
    var currentYearValue: String!

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
        setupGraphScrollControl()
        dailyNotificationRequester()
    }
    
    // Setup graph scroll views to page controller
    func setupGraphScrollControl() {
        // Setting default page control values
        self.PageControl.numberOfPages = 3
        self.PageControl.currentPage = 0
        
//        self.PageControl.tintColor = UIColor.red
//        self.PageControl.pageIndicatorTintColor = UIColor.black
//        self.PageControl.currentPageIndicatorTintColor = UIColor.green
        
        // Setting default scroll view values
        for index in 0..<numberOfGraphs {
            frame.origin.x = GraphScrollView.frame.size.width * CGFloat(index)
            frame.size = GraphScrollView.frame.size
            let graphView = UIView(frame: frame)
            // Creating graphs for each view
            switch index {
                // Create graph A - Horizontal Bar Chart (Monthly)
                case 0:
                    self.GraphScrollView.addSubview(setupHorizontalBarChart(graphView: graphView))
                // TODO:
                // Create graph B
                case 1:
                    graphView.backgroundColor = UIColor.black
                    self.GraphScrollView.addSubview(graphView)
                // TODO:
                // Create graph C
                case 2:
                    graphView.backgroundColor = UIColor.green
                    self.GraphScrollView.addSubview(graphView)
                default:
                    self.GraphScrollView.addSubview(UIView(frame: frame))
                    NSLog("Failed to generate graph, index out of bounds of expected values. Try updating 'numberOfGraphs'")
            }
        }
        GraphScrollView.contentSize = CGSize(width: (GraphScrollView.frame.size.width * CGFloat(numberOfGraphs)), height: GraphScrollView.frame.size.height)
        GraphScrollView.delegate = self
    }
    
    // Keeps track of current scroll view focus on deceleration
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = GraphScrollView.contentOffset.x / GraphScrollView.frame.size.width
        PageControl.currentPage = Int(pageNumber)
    }
    
    // Setup graph A - Horizontal Bar Chart (Monthly)
    func setupHorizontalBarChart(graphView: UIView) -> HorizontalBarChartView {
        let chartView: HorizontalBarChartView = HorizontalBarChartView(frame: graphView.frame)
        chartView.isUserInteractionEnabled = false
        
        // Xaxis setup
        let xAxis = chartView.xAxis
        xAxis.labelPosition = .bottomInside
        xAxis.labelFont = UIFont(name: "Lato-Regular", size: 15.0)!
        xAxis.labelTextColor = UIColor.white
        xAxis.drawAxisLineEnabled = true
        xAxis.granularity = 5
        xAxis.gridColor = UIColor.white
        
        // Leftaxis setup
        let leftAxis = chartView.leftAxis
        leftAxis.labelFont = UIFont(name: "Lato-Regular", size: 15.0)!
        leftAxis.labelTextColor = UIColor.white
        leftAxis.drawAxisLineEnabled = true
        leftAxis.drawGridLinesEnabled = true
        leftAxis.axisMinimum = 0
        leftAxis.gridColor = UIColor.white
        
        // Rightaxis setup
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = true
        rightAxis.labelFont = UIFont(name: "Lato-Regular", size: 15.0)!
        rightAxis.labelTextColor = UIColor.white
        rightAxis.drawAxisLineEnabled = true
        rightAxis.axisMinimum = 0
        rightAxis.gridColor = UIColor.white
        
        // Legend setup
        let l = chartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .square
        l.formSize = 0
        l.font = UIFont(name: "Lato-Regular", size: 20.0)!
        l.textColor = UIColor.white
        l.xEntrySpace = 4
        l.enabled = true
        
        // Extra settings
        chartView.fitBars = true
        chartView.animate(yAxisDuration: 2.5)
        chartView.noDataText = "No relevant smile entry data."
        chartView.noDataTextColor = UIColor.white
        chartView.noDataFont = UIFont(name: "Lato-Regular", size: 15.0)!
        
        // Data Configuration
        var dataEntries: [BarChartDataEntry] = []
        let dataPoints = ["Neutral", "Happy", "Sad", "Angry", "Love", "Excitement", "Suprise"]
        let values = getDataPointValuesForGraphA()
        
        chartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)
        chartView.chartDescription?.enabled = false
        
        chartView.xAxis.granularity = 1.0
        chartView.xAxis.labelCount = dataPoints.count
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: [values[i]])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: ("Smile Entries for " + currentMonthValue + "/" + currentYearValue))
        let chartData = BarChartData(dataSet: chartDataSet)
        chartView.data = chartData
        
        // Hide bar value text
        chartView.data?.setValueTextColor(UIColor.clear)
        
        // Return completed Horizontal Bar Chart
        return chartView
    }
    
    // Get data point values for graph A - Horizontal Bar Chart (Monthly)
    func getDataPointValuesForGraphA() -> [Double] {
        var values = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        
        // Get the current month
        if (Int(currentMonthValue)! < 10) {
            currentMonthValue = "0" + currentMonthValue
        }
        
        // Look through all data entries
        for dayEntry in dayEntryData {
            // Pull out month and year substrings from data entry timestamp
            let start = dayEntry.timestamp.index(dayEntry.timestamp.startIndex, offsetBy: 5)
            let end = dayEntry.timestamp.index(dayEntry.timestamp.endIndex, offsetBy: -9)
            let range = start..<end
            let dayEntryMonthValue = dayEntry.timestamp[range]
            let dayEntryYearValue = dayEntry.timestamp.prefix(4)
            
            // Check if data entry is from the current year and month
            if (dayEntryYearValue == currentYearValue && dayEntryMonthValue == currentMonthValue) {
                // Increment values based on smile type in data entry
                values[dayEntry.smileEntry.value!] += 1.0
            }
        }
        
        // Return completed data point values array
        return values
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
        currentYearValue = currentYear
        let currentMonth = String(dateTimeComponents.month!) // 7
        currentMonthValue = currentMonth
        let currentDay = String(dateTimeComponents.day!) // 1
        let formatter = DateFormatter()
        let currentWeekday = String(formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1])
        // Setting outlet values
        CurrentWeekdayNameLabel.text = currentWeekday
        CurrentDateLabel.text = currentMonth + "/" + currentDay + "/" + currentYear
    }
    
    // userDefaults custom data type storage: https:\\stackoverflow.com/questions/37980432/swift-3-saving-and-retrieving-custom-object-from-userdefaults
}

