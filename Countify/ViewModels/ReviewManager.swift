//
//  ReviewManager.swift
//  Countify
//
//  Created by Throw Catchers on 3/8/25.
//

import Foundation
import StoreKit
import SwiftUI

/// Manages app review requests based on user interactions
class ReviewManager {
    static let shared = ReviewManager()
    
    // Keys for UserDefaults
    private let lastReviewRequestDateKey = "LastReviewRequestDate"
    private let successfulInteractionsKey = "SuccessfulInteractions"
    private let sessionCountKey = "SessionCount"
    
    private init() {}
    
    // MARK: - User Interaction Tracking
    
    /// Record a successful interaction (like creating a counter or reaching a goal)
    func registerSuccessfulInteraction() {
        let currentCount = UserDefaults.standard.integer(forKey: successfulInteractionsKey)
        UserDefaults.standard.set(currentCount + 1, forKey: successfulInteractionsKey)
        
        checkAndRequestReview()
    }
    
    /// Record a new app session
    func registerAppSession() {
        let currentCount = UserDefaults.standard.integer(forKey: sessionCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: sessionCountKey)
    }
    
    // MARK: - Review Request Logic
    
    /// Check if conditions are right to request a review
    private func checkAndRequestReview() {
        // Don't request reviews too frequently
        guard daysSinceLastRequest() >= 30 else { return }
        
        let interactionCount = UserDefaults.standard.integer(forKey: successfulInteractionsKey)
        let sessionCount = UserDefaults.standard.integer(forKey: sessionCountKey)
        
        // Request review if:
        // 1. User has had at least 5 successful interactions, OR
        // 2. User has opened the app at least 10 times
        if interactionCount >= 5 || sessionCount >= 10 {
            requestReview()
        }
    }
    
    /// Request a review at an appropriate time
    func requestReview() {
        // Update the last request date
        UserDefaults.standard.set(Date(), forKey: lastReviewRequestDateKey)
        
        // Reset the counters
        UserDefaults.standard.set(0, forKey: successfulInteractionsKey)
        
        // Request the review (will only show if Apple's frequency algorithm allows it)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                // Check if we're on iOS 18+ and use the new API
                if #available(iOS 18.0, *) {
                    AppStore.requestReview(in: scene)
                } else {
                    // Use the older API for iOS 17 and below
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Calculate days since last review request
    private func daysSinceLastRequest() -> Int {
        guard let lastDate = UserDefaults.standard.object(forKey: lastReviewRequestDateKey) as? Date else {
            return Int.max // No previous request
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: lastDate, to: Date())
        return components.day ?? Int.max
    }
}

// MARK: - SwiftUI Extension for View

extension View {
    /// Register a successful interaction when a certain condition is met
    func requestReviewAfterSuccess(if condition: Bool) -> some View {
        if condition {
            ReviewManager.shared.registerSuccessfulInteraction()
        }
        return self
    }
}
