//
//  Smile.swift
//  Smile Report
//
//  Created by Dylan Rothfeld on 6/23/18.
//  Copyright © 2018 Dylan Rothfeld. All rights reserved.
//

import UIKit

class Smile {
    let name: String
    let value: Int?
    let image: UIImage?
    
    // Smile initializer
    init(value: Int) {
        self.value = value
        
        // Assinging name and image based on value
        // TODO: Add actual image files for each smile
        switch(value) {
            // Neutral
            case 0:
                self.name = "Neutral"
                self.image = #imageLiteral(resourceName: "neutral-face.png")
            
            // Happy
            case 1:
                self.name = "Happy"
                self.image = #imageLiteral(resourceName: "happy-face.png")
            
            // Sad
            case 2:
                self.name = "Sad"
                self.image = #imageLiteral(resourceName: "sad-face.png")
            
            // Angry
            case 3:
                self.name = "Angry"
                self.image = #imageLiteral(resourceName: "angry-face.png")
            
            // Love
            case 4:
                self.name = "Love"
                self.image = #imageLiteral(resourceName: "love-face.png")
            
            // Excitement
            case 5:
                self.name = "Excitement"
                self.image = #imageLiteral(resourceName: "excitement-face.png")
            
            // Suprise
            case 6:
                self.name = "Surprise"
                self.image = #imageLiteral(resourceName: "surprise-face.png")
            
            // Should never reach here
            default:
                self.name = ""
                self.image = nil
        }
    }
}
