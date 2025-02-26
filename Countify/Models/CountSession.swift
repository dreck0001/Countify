//
//  CountSession.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import Foundation

struct CountSession: Identifiable, Codable {
    let id: UUID
    var name: String
    var count: Int
    var date: Date
    var hapticEnabled: Bool
    var allowNegatives: Bool
    var stepSize: Int
    var upperLimit: Int?
    var lowerLimit: Int?
    
    init(id: UUID = UUID(),
         name: String = "New Count",
         count: Int = 0,
         date: Date = Date(),
         hapticEnabled: Bool = true,
         allowNegatives: Bool = false,
         stepSize: Int = 1,
         upperLimit: Int? = nil,
         lowerLimit: Int? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.hapticEnabled = hapticEnabled
        self.allowNegatives = allowNegatives
        self.stepSize = max(1, stepSize)  // Ensure step size is never less than 1
        
        // Ensure limits are valid if provided
        if let upper = upperLimit, let lower = lowerLimit {
            self.upperLimit = max(upper, lower + stepSize)
            self.lowerLimit = min(lower, upper - stepSize)
        } else {
            self.upperLimit = upperLimit
            self.lowerLimit = lowerLimit
        }
        
        // Adjust count to respect limits
        var adjustedCount = count
        if let lower = lowerLimit, adjustedCount < lower {
            adjustedCount = lower
        }
        if let upper = upperLimit, adjustedCount > upper {
            adjustedCount = upper
        }
        self.count = adjustedCount
    }
    
    // Helper computed properties
    var isAtUpperLimit: Bool {
        guard let upperLimit = upperLimit else { return false }
        return count >= upperLimit
    }
    
    var isAtLowerLimit: Bool {
        guard let lowerLimit = lowerLimit else { return false }
        return count <= lowerLimit
    }
}
