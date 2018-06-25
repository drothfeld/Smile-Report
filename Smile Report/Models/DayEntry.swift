//
//  DayEntry.swift
//  Smile Report
//
//  Created by Dylan Rothfeld on 6/23/18.
//  Copyright © 2018 Dylan Rothfeld. All rights reserved.
//

import Foundation

class DayEntry: NSObject, NSCoding {
    let timestamp: String
    let smileEntry: Smile
    
    // DayEntry initializer
    init(timestamp: String, smileEntry: Smile) {
        self.timestamp = timestamp
        self.smileEntry = smileEntry
    }
    
    // Decoding for userdefaults
    required init(coder decoder: NSCoder) {
        self.timestamp = decoder.decodeObject(forKey: "timestamp") as? String ?? ""
        self.smileEntry = (decoder.decodeObject(forKey: "smileEntry") as? Smile)!
    }
    
    // Encoding for userdefaults
    func encode(with coder: NSCoder) {
        coder.encode(timestamp, forKey: "timestamp")
        coder.encode(smileEntry, forKey: "asmileEntryge")
    }
    
}
