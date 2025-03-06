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
    var favorite: Bool
    
    init(id: UUID = UUID(),
         name: String = "New Count",
         count: Int = 0,
         date: Date = Date(),
         hapticEnabled: Bool = true,
         allowNegatives: Bool = false,
         stepSize: Int = 1,
         upperLimit: Int? = nil,
         lowerLimit: Int? = nil,
         favorite: Bool = false) {
        self.id = id
        self.name = name
        self.date = date
        self.hapticEnabled = hapticEnabled
        self.allowNegatives = allowNegatives
        self.stepSize = max(1, stepSize)
        self.favorite = favorite
        
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

extension CountSession {
    // Check if increment by step size is allowed
    var canIncrement: Bool {
        guard let upperLimit = upperLimit else { return true }
        return count + stepSize <= upperLimit
    }
    
    // Check if decrement by step size is allowed
    var canDecrement: Bool {
        if let lowerLimit = lowerLimit {
            return count - stepSize >= lowerLimit
        }
        return allowNegatives || count >= stepSize
    }
    
    // Safe increment that respects limits
    mutating func incrementWithinLimits() -> Bool {
        if canIncrement {
            count += stepSize
            return true
        } else if let upperLimit = upperLimit, count < upperLimit {
            // If we can't increment by full step size but can get closer to limit
            count = upperLimit
            return true
        }
        return false
    }
    
    // Safe decrement that respects limits
    mutating func decrementWithinLimits() -> Bool {
        if canDecrement {
            count -= stepSize
            return true
        } else if let lowerLimit = lowerLimit, count > lowerLimit {
            // If we can't decrement by full step size but can get closer to limit
            count = lowerLimit
            return true
        } else if !allowNegatives && count > 0 && count < stepSize {
            // If we can't go below zero but can get to zero
            count = 0
            return true
        }
        return false
    }
}
