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
    
    var body: some View {
        Button(action: {
            if session.allowNegatives || session.count > 0 {
                isIncrementing = false
                if session.hapticEnabled {
                    HapticManager.shared.playHaptic(style: .decrement)
                }
                session.count -= 1
                onSave()
            }
        }) {
            Text("−")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.red)
                .frame(width: 60, height: 60)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Decrease count")
        .accessibilityHint("Double tap feedback will occur when pressed")
    }
}

struct IncrementButton: View {
    @Binding var session: CountSession
    @Binding var isIncrementing: Bool
    let onSave: () -> Void
    
    var body: some View {
        Button(action: {
            isIncrementing = true
            if session.hapticEnabled {
                HapticManager.shared.playHaptic(style: .increment)
            }
            session.count += 1
            onSave()
        }) {
            Text("+")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.green)
                .frame(width: 60, height: 60)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Increase count")
        .accessibilityHint("Single tap feedback will occur when pressed")
    }
}

//#Preview {
//    CounterButtons()
//}
