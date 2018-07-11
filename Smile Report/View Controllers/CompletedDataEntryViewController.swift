//
//  CompletedDataEntryViewController.swift
//  Smile Report
//
//  Created by Dylan Rothfeld on 7/11/18.
//  Copyright © 2018 Dylan Rothfeld. All rights reserved.
//

import UIKit

class CompletedDataEntryViewController: UIViewController {
    // Storyboard Outlets
    @IBOutlet weak var ChosenSmileImage: UIImageView!
    @IBOutlet weak var ChosenSmileNameLabel: UILabel!
    
    // Controller Values
    var chosenSmile: Smile! = nil
    var segueTimer: Timer = Timer()
    let segueTimerValue: Double = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        interfaceSetup()
        startSegueTimer()
    }
    
    // Change any interface settings
    func interfaceSetup() {
        ChosenSmileImage.image = chosenSmile.image
        ChosenSmileNameLabel.text = chosenSmile.name
    }
    
    // Segue back to home after timer expires
    @objc func segueToHome() {
        performSegue(withIdentifier: "completedToHome", sender: self)
    }
    
    // Starts segue timer
    func startSegueTimer() {
        segueTimer = Timer.scheduledTimer(timeInterval: segueTimerValue, target: self, selector: (#selector(CompletedDataEntryViewController.segueToHome)), userInfo: nil, repeats: false)
    }
}

