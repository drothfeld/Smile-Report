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
    var currentDayValue: String!
    var largestDataTypeMonthCount = 0
    var allDataYears: [String] = []

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
        setupGraphScrollControl()
        setStatusMessage()
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
                
                // Create graph A - Horizontal Bar Chart (Current Month)
                case 0:
                    self.GraphScrollView.addSubview(setupHorizontalBarChart(graphView: graphView))
                
                // Create graph B - Radar Chart (Cumulative positive/negative smiles during seasons/months)
                case 1:
                    self.GraphScrollView.addSubview(setupRadarChart(graphView: graphView))
                
                // Create graph C - Bar Chart (Grouped Dataset for neutral/positive/negative emotion counts for each year)
                case 2:
                    self.GraphScrollView.addSubview(setupBarChart(graphView: graphView))
                
                // Shouldn't ever happen
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
    
    // Setup graph A - Horizontal Bar Chart (Current Month)
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
        let dataPoints = ["Neutral", "Happy", "Sad", "Angry", "Love", "Excitement", "Surprise"]
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
        var largestEmotionCountForRadarPos = 0
        var largestEmotionCountForRadarNeg = 0
        var currentMonth = "01"
        
        // Get the current month
        if (Int(currentMonthValue)! < 10) {
            currentMonthValue = "0" + currentMonthValue
        }
        
        // Look through all data entries
        for dayEntry in dayEntryData {
            
            // Pull out day substring from data entry timestamp
            let startDay = dayEntry.timestamp.index(dayEntry.timestamp.startIndex, offsetBy: 8)
            let endDay = dayEntry.timestamp.index(dayEntry.timestamp.endIndex, offsetBy: -6)
            let rangeDay = startDay..<endDay
            let dayEntryDayValue = dayEntry.timestamp[rangeDay]
            
            // Pull out month substring from data entry timestamp
            let startMonth = dayEntry.timestamp.index(dayEntry.timestamp.startIndex, offsetBy: 5)
            let endMonth = dayEntry.timestamp.index(dayEntry.timestamp.endIndex, offsetBy: -9)
            let rangeMonth = startMonth..<endMonth
            let dayEntryMonthValue = dayEntry.timestamp[rangeMonth]
            
            // Pull out year substring from data entry timestamp
            let dayEntryYearValue = dayEntry.timestamp.prefix(4)
            
            // Check if a data entry has been made for the current day/month/year
            if (dayEntryDayValue == currentDayValue && dayEntryMonthValue == currentMonthValue && dayEntryYearValue == currentYearValue) {
                dataPointEnteredToday = true
            }
            
            // Check if data entry year exists in global list yet
            if (!isYearRecorded(yearInQuestion: String(dayEntryYearValue))) {
                allDataYears.append(String(dayEntryYearValue))
            }
            
            // Check if new month to reset counter
            if (dayEntryMonthValue != currentMonth) {
                if (largestEmotionCountForRadarPos > largestDataTypeMonthCount) {
                    largestDataTypeMonthCount = largestEmotionCountForRadarPos
                }
                if (largestEmotionCountForRadarPos > largestDataTypeMonthCount) {
                    largestDataTypeMonthCount = largestEmotionCountForRadarNeg
                }
                currentMonth = String(dayEntryMonthValue)
                largestEmotionCountForRadarPos = 0
                largestEmotionCountForRadarNeg = 0
                
            // Increment either positive or negative counter
            } else {
                if (dayEntry.smileEntry.value == smile_happy.value || dayEntry.smileEntry.value == smile_love.value || dayEntry.smileEntry.value == smile_excitement.value) {
                    largestEmotionCountForRadarPos += 1
                }
                if (dayEntry.smileEntry.value == smile_sad.value || dayEntry.smileEntry.value == smile_angry.value) {
                    largestEmotionCountForRadarNeg += 1
                }
            }
            
            // Check if data entry is from the current year and month
            if (dayEntryYearValue == currentYearValue && dayEntryMonthValue == currentMonthValue) {
                // Increment values based on smile type in data entry
                values[dayEntry.smileEntry.value!] += 1.0
            }
        }
        
        // Return completed data point values array
        return values
    }
    
    // Create graph B - Radar Chart (Cumulative positive/negative smiles during seasons/months)
    func setupRadarChart(graphView: UIView) -> RadarChartView {
        let chartView: RadarChartView = RadarChartView(frame: graphView.frame)
        chartView.isUserInteractionEnabled = false
        
        // Main Settings
        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sept", "Oct", "Nov", "Dec"]
        
        // Extra Settings
        chartView.chartDescription?.enabled = false
        chartView.webLineWidth = 1
        chartView.innerWebLineWidth = 1
        chartView.webColor = .white
        chartView.innerWebColor = .white
        chartView.webAlpha = 1
        chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        chartView.noDataText = "No relevant smile entry data."
        chartView.noDataTextColor = UIColor.white
        chartView.noDataFont = UIFont(name: "Lato-Regular", size: 15.0)!

        
        // Xaxis Settings
        let xAxis = chartView.xAxis
        xAxis.labelFont = UIFont(name: "Lato-Regular", size: 15.0)!
        xAxis.labelPosition = XAxis.LabelPosition(rawValue: 1)!
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.labelTextColor = .white
        xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
        xAxis.granularity = 1.0
        
        // yAxis Settings
        let yAxis = chartView.yAxis
        yAxis.labelFont = UIFont(name: "Lato-Regular", size: 15.0)!
        yAxis.labelCount = 5
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = Double(largestDataTypeMonthCount) // Graph Maximum Value Range
        yAxis.drawLabelsEnabled = false
        
        // Legend Settings
        let l = chartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.font = UIFont(name: "Lato-Regular", size: 15.0)!
        l.xEntrySpace = 7
        l.yEntrySpace = 5
        l.textColor = .white
        l.enabled = false
        
        // Data Configuration
        var dataEntriesPos: [RadarChartDataEntry] = []
        var dataEntriesNeg: [RadarChartDataEntry] = []
        let valuesPos = getDataPointValuesPosForGraphB()
        let valuesNeg = getDataPointValuesNegForGraphB()
        
        for i in 0..<months.count {
            let dataEntryPos = RadarChartDataEntry(value: valuesPos[i])
            let dataEntryNeg = RadarChartDataEntry(value: valuesNeg[i])
            dataEntriesPos.append(dataEntryPos)
            dataEntriesNeg.append(dataEntryNeg)
        }
        
        // Positive emotions
        let set1 = RadarChartDataSet(values: dataEntriesPos, label: "Positive Emotions")
        set1.setColor(.green)
        set1.fillColor = UIColor.green
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)
        
        // Negative emotions
        let set2 = RadarChartDataSet(values: dataEntriesNeg, label: "Negative Emotions")
        set2.setColor(.red)
        set2.fillColor = UIColor.red
        set2.drawFilledEnabled = true
        set2.fillAlpha = 0.7
        set2.lineWidth = 2
        set2.drawHighlightCircleEnabled = true
        set2.setDrawHighlightIndicators(false)
        
        let data = RadarChartData(dataSets: [set1, set2])
        data.setValueFont(UIFont(name: "Lato-Regular", size: 20.0)!)
        data.setDrawValues(false)
        data.setValueTextColor(.white)
        
        chartView.data = data
        
        // Return completed Radar Chart
        return chartView
    }
    
    // Get Pos data point values for graph B Radar Chart (Cumulative positive/negative smiles during seasons/months)
    func getDataPointValuesPosForGraphB() -> [Double] {
        var positiveEmotionsForEachMonth = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ,0.0]
        
        // Look through all data entries
        for dayEntry in dayEntryData {
            // Pull out month and year substrings from data entry timestamp
            let start = dayEntry.timestamp.index(dayEntry.timestamp.startIndex, offsetBy: 5)
            let end = dayEntry.timestamp.index(dayEntry.timestamp.endIndex, offsetBy: -9)
            let range = start..<end
            var dayEntryMonthValue = dayEntry.timestamp[range]
            let dayEntryYearValue = dayEntry.timestamp.prefix(4)
            
            // Check for leading zero on month value to prevent casting error
            if (dayEntryMonthValue.prefix(1) == "0") {
                dayEntryMonthValue = dayEntryMonthValue.dropFirst()
            }
            
            // Check if data entry is from the current year
            if (dayEntryYearValue == currentYearValue) {
                // Increment positiveEmotionsForEachMonth based on smile type in data entry
                    if (dayEntry.smileEntry.value == smile_happy.value || dayEntry.smileEntry.value == smile_love.value || dayEntry.smileEntry.value == smile_excitement.value) {
                        positiveEmotionsForEachMonth[Int(dayEntryMonthValue)! - 1] += 1.0
                    }
            }
        }
        
        // Return completed data point values array
        return positiveEmotionsForEachMonth
    }
    
    // Get Neg data point values for graph B Radar Chart (Cumulative positive/negative smiles during seasons/months)
    func getDataPointValuesNegForGraphB() -> [Double] {
        var negativeEmotionsForEachMonth = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ,0.0]
        
        // Look through all data entries
        for dayEntry in dayEntryData {
            // Pull out month and year substrings from data entry timestamp
            let start = dayEntry.timestamp.index(dayEntry.timestamp.startIndex, offsetBy: 5)
            let end = dayEntry.timestamp.index(dayEntry.timestamp.endIndex, offsetBy: -9)
            let range = start..<end
            var dayEntryMonthValue = dayEntry.timestamp[range]
            let dayEntryYearValue = dayEntry.timestamp.prefix(4)
            
            // Check for leading zero on month value to prevent casting error
            if (dayEntryMonthValue.prefix(1) == "0") {
                dayEntryMonthValue = dayEntryMonthValue.dropFirst()
            }
            
            // Check if data entry is from the current year
            if (dayEntryYearValue == currentYearValue) {
                // Increment negativeEmotionsForEachMonth based on smile type in data entry
                if (dayEntry.smileEntry.value == smile_sad.value || dayEntry.smileEntry.value == smile_angry.value) {
                    negativeEmotionsForEachMonth[Int(dayEntryMonthValue)! - 1] += 1.0
                }
            }
        }
        
        // Return completed data point values array
        return negativeEmotionsForEachMonth
    }
    
    // Setup graph C - Bar Chart (Grouped Dataset for neutral/positive/negative emotion counts for each year)
    func setupBarChart(graphView: UIView) -> BarChartView {
        let chartView: BarChartView = BarChartView(frame: graphView.frame)
        chartView.isUserInteractionEnabled = false
        
        // Main Settings
        // Hide bar value text
        chartView.data?.setValueTextColor(UIColor.clear)
        chartView.chartDescription?.enabled = false
        
        // Extra Settings
        chartView.chartDescription?.enabled = false
        chartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
        chartView.noDataText = "No relevant smile entry data."
        chartView.noDataTextColor = UIColor.white
        chartView.noDataFont = UIFont(name: "Lato-Regular", size: 15.0)!
        
        // Legend Settings
        let legend = chartView.legend
        legend.enabled = false
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = true
        legend.yOffset = 10.0;
        legend.xOffset = 9.0;
        legend.yEntrySpace = 0.0;
        legend.textColor = .white
        legend.font = UIFont(name: "Lato-Regular", size: 10.0)!
        
        // xAxis Settings
        let xAxis = chartView.xAxis
        //xAxis.valueFormatter = axisFormatDelegate
        xAxis.drawGridLinesEnabled = true
        xAxis.labelPosition = .bottom
        xAxis.gridColor = .white
        xAxis.centerAxisLabelsEnabled = true
        xAxis.labelFont = UIFont(name: "Lato-Regular", size: 15.0)!
        xAxis.labelTextColor = .white
        xAxis.valueFormatter = IndexAxisValueFormatter(values: allDataYears)
        xAxis.granularity = 1
        
        // leftAxis and rightAxis Settings
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.maximumFractionDigits = 1
        chartView.rightAxis.enabled = false
        
        // yAxis Settings
        let yAxis = chartView.leftAxis
        yAxis.spaceTop = 0.35
        yAxis.axisMinimum = 0
        yAxis.gridColor = .white
        yAxis.labelTextColor = .white
        yAxis.labelFont = UIFont(name: "Lato-Regular", size: 15.0)!
        yAxis.drawGridLinesEnabled = false
        
        // Data Configuration
        var dataEntriesPositive: [BarChartDataEntry] = []
        var dataEntriesNegative: [BarChartDataEntry] = []
        var dataEntriesNeutral: [BarChartDataEntry] = []
        var yearlyCountData = getDataPointValuesForGraphC()
        var yearlyPositiveCount = yearlyCountData[0] // [# of pos emotions for year 1, # of pos emotions for year 2, etc..]
        var yearlyNegativeCount = yearlyCountData[1] // [# of neg emotions for year 1, # of neg emotions for year 2, etc..]
        var yearlyNeutralCount = yearlyCountData[2]  // [# of neu emotions for year 1, # of neu emotions for year 2, etc..]
        
        for i in 0..<allDataYears.count {
            
            // Data entry for positive emotions
            let dataEntryPositive = BarChartDataEntry(x: Double(i) , y: Double(yearlyPositiveCount[i]))
            dataEntriesPositive.append(dataEntryPositive)
            
            // Data entry for negative emotions
            let dataEntryNegative = BarChartDataEntry(x: Double(i) , y: Double(yearlyNegativeCount[i]))
            dataEntriesNegative.append(dataEntryNegative)
            
            // Data entry for neutral emotions
            let dataEntryNeutral = BarChartDataEntry(x: Double(i) , y: Double(yearlyNeutralCount[i]))
            dataEntriesNeutral.append(dataEntryNeutral)
        }
        
        let chartDataSetPositive = BarChartDataSet(values: dataEntriesPositive, label: "Positive Emotions")
        let chartDataSetNegative = BarChartDataSet(values: dataEntriesNegative, label: "Negative Emotions")
        let chartDataSetNeutral  = BarChartDataSet(values: dataEntriesNeutral, label: "Neutral Emotions")
        
        let dataSets: [BarChartDataSet] = [chartDataSetPositive, chartDataSetNegative, chartDataSetNeutral]
        chartDataSetPositive.colors = [UIColor(red: 50/255, green: 255/255, blue: 50/255, alpha: 0.85)]
        chartDataSetNegative.colors = [UIColor(red: 255/255, green: 50/255, blue: 50/255, alpha: 0.85)]
        chartDataSetNeutral.colors  = [UIColor(red: 50/255, green: 50/255, blue: 255/255, alpha: 0.85)]
        
        let chartData = BarChartData(dataSets: dataSets)
        
        // (groupSpace * barSpace) * n + groupSpace = 1
        // (0.2 + 0.03) * 3 + 0.08 = 1.00 -> interval per "group"
        let groupSpace = 0.2
        let barSpace = 0.03
        let barWidth = 0.24
        
        let groupCount = allDataYears.count
        let startYear = 0
        
        chartData.barWidth = barWidth
        chartView.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        chartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        
        chartView.data = chartData
        
        // Hide bar value text
        chartView.data?.setValueTextColor(UIColor.clear)
        
        // Return completed Group Data Bar Chart
        return chartView
    }
    
    // Get data point values for graph C - Bar Chart (Grouped Dataset for neutral/positive/negative emotion counts for each year)
    func getDataPointValuesForGraphC() -> [[Int]] {
        var yearlyCountData = Array(repeating: Array(repeating: 0, count: allDataYears.count), count: 3)
        
        // For each year in the dataYear group
        for (index, year) in allDataYears.enumerated() {
            
            // Look through all data entries
            for dayEntry in dayEntryData {
                
                // Pull out year substrings from data entry timestamp
                let dayEntryYearValue = dayEntry.timestamp.prefix(4)
                
                // Check if dataEntry is in the year we are looking at
                if (year == String(dayEntryYearValue)) {
                    
                    // Check if emotion is positive
                    if (dayEntry.smileEntry.value == smile_happy.value || dayEntry.smileEntry.value == smile_love.value || dayEntry.smileEntry.value == smile_excitement.value) {
                        yearlyCountData[0][index] += 1
                    }
                    
                    // Check if emotion is negative
                    if (dayEntry.smileEntry.value == smile_sad.value || dayEntry.smileEntry.value == smile_angry.value) {
                        yearlyCountData[1][index] += 1
                    }
                    
                    // Check if emotion is neutral
                    if (dayEntry.smileEntry.value == smile_neutral.value || dayEntry.smileEntry.value == smile_surpise.value) {
                        yearlyCountData[2][index] += 1
                    }
                }
            }
        }
        
        return yearlyCountData
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
//            StatusMessageLabel.textColor = .green
        } else {
            StatusMessageLabel.text = "Missing Daily Entry"
//            StatusMessageLabel.textColor = .red
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
        currentDayValue = currentDay
        let formatter = DateFormatter()
        let currentWeekday = String(formatter.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1])
        // Setting outlet values
        CurrentWeekdayNameLabel.text = currentWeekday
        CurrentDateLabel.text = currentMonth + "/" + currentDay + "/" + currentYear
    }
    
    // Check if year is already in data entry years list
    func isYearRecorded(yearInQuestion: String) -> Bool {
        // Check if year is in list
        for year in allDataYears {
            if (year == yearInQuestion) {
                return true
            }
        }
        return false
    }
    
    // User presses the addDataPoint button
    @IBAction func addDataPointButtonPressed(_ sender: Any) {
        // Check if the user has already entered data today
        if (dataPointEnteredToday) {
            setStatusMessage()
        } else {
            performSegue(withIdentifier: "addDataPoint", sender: self)
        }
    }
    
    // userDefaults custom data type storage: https:\\stackoverflow.com/questions/37980432/swift-3-saving-and-retrieving-custom-object-from-userdefaults
}

