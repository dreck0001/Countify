//
//  HapticManager.swift
//  Countify
//
//  Created by Throw Catchers on 2/17/25.
//

import Foundation
import UIKit

enum HapticStyle {
    case increment
    case decrement
}

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    func playHaptic(style: HapticStyle) {
        switch style {
        case .increment:
            // Single crisp tap for increment
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 0.8)
            
        case .decrement:
            // Double tap pattern for decrement (two distinct taps)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 0.7)
            
            // Second tap after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let secondGenerator = UIImpactFeedbackGenerator(style: .medium)
                secondGenerator.prepare()
                secondGenerator.impactOccurred(intensity: 0.7)
            }
        }
    }
}
