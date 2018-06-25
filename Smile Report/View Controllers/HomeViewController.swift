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
    
    // Controller Values
    var dayEntryData: [DayEntry] = mockData

    override func viewDidLoad() {
        super.viewDidLoad()
        interfaceSetup()
    }
    
    func interfaceSetup() {
        // Changing status bar to white text
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    // userDefaults custom data type storage: https:\\stackoverflow.com/questions/37980432/swift-3-saving-and-retrieving-custom-object-from-userdefaults
    // Hooking up page control with scroll view: https:\\www.youtube.com/watch?v=X2Wr4TtMG6Q

}

