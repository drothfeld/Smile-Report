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
    let smileEntryIndex: Int
    
    // DayEntry initializer
    init(timestamp: String, smileEntryIndex: Int) {
        self.timestamp = timestamp
        self.smileEntryIndex = smileEntryIndex
    }
    
    // Decoding for userdefaults
    required convenience init(coder decoder: NSCoder) {
        let timestamp = decoder.decodeObject(forKey: "timestamp") as? String ?? ""
        let smileEntryIndex = decoder.decodeInteger(forKey: "smileEntryIndex")
        self.init(timestamp: timestamp, smileEntryIndex: smileEntryIndex)
    }
    
    // Encoding for userdefaults
    func encode(with coder: NSCoder) {
        coder.encode(timestamp, forKey: "timestamp")
        coder.encode(smileEntryIndex, forKey: "smileEntryIndex")
    }
    
}
