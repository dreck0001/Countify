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
        session.canDecrement
    }
    
    var body: some View {
        Button(action: {
            if canDecrement {
                isIncrementing = false
                if session.hapticEnabled {
                    HapticManager.shared.playHaptic(style: .decrement)
                }
                
                var updatedSession = session
                _ = updatedSession.decrementWithinLimits()
                session = updatedSession
                
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
        session.canIncrement
    }
    
    var body: some View {
        Button(action: {
            if canIncrement {
                isIncrementing = true
                if session.hapticEnabled {
                    HapticManager.shared.playHaptic(style: .increment)
                }
                
                var updatedSession = session
                _ = updatedSession.incrementWithinLimits()
                session = updatedSession
                
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
