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
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                }
                session.count -= 1
                onSave()
            }
        }) {
            Text("−")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.red)
                .frame(width: 40, height: 40)
        }
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
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
            session.count += 1
            onSave()
        }) {
            Text("+")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.green)
                .frame(width: 40, height: 40)
        }
    }
}

//#Preview {
//    CounterButtons()
//}
