//
//  CounterButtons.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct DecrementButton: View {
    @Binding var session: CountSession
    @Binding var isIncrementing: Bool
    let onSave: () -> Void
    
    private var canDecrement: Bool {
        // If there's a lower limit, check against it
        if let lowerLimit = session.lowerLimit {
            return session.count > lowerLimit
        }
        // Otherwise, check if negatives are allowed or if count is positive
        return session.allowNegatives || session.count > 0
    }
    
    var body: some View {
        Button(action: {
            if canDecrement {
                isIncrementing = false
                if session.hapticEnabled {
                    HapticManager.shared.playHaptic(style: .decrement)
                }
                session.count -= session.stepSize
                onSave()
            }
        }) {
            Text("−")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(canDecrement ? .red : .gray)
                .frame(width: 60, height: 60)
                .contentShape(Rectangle())
        }
        .disabled(!canDecrement)
        .accessibilityLabel("Decrease count by \(session.stepSize)")
        .accessibilityHint("Double tap feedback will occur when pressed")
    }
}

struct IncrementButton: View {
    @Binding var session: CountSession
    @Binding var isIncrementing: Bool
    let onSave: () -> Void
    
    private var canIncrement: Bool {
        // If there's an upper limit, check against it
        if let upperLimit = session.upperLimit {
            return session.count < upperLimit
        }
        // No upper limit, always allow increment
        return true
    }
    
    var body: some View {
        Button(action: {
            if canIncrement {
                isIncrementing = true
                if session.hapticEnabled {
                    HapticManager.shared.playHaptic(style: .increment)
                }
                session.count += session.stepSize
                onSave()
            }
        }) {
            Text("+")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(canIncrement ? .green : .gray)
                .frame(width: 60, height: 60)
                .contentShape(Rectangle())
        }
        .disabled(!canIncrement)
        .accessibilityLabel("Increase count by \(session.stepSize)")
        .accessibilityHint("Single tap feedback will occur when pressed")
    }
}
//#Preview {
//    CounterButtons()
//}
