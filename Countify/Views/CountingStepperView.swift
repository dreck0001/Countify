//
//  CountingStepperView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct CountingStepperView: View {
    @State var session: CountSession
    @ObservedObject var sessionManager: CountSessionManager
    @State private var isIncrementing = true
    @Environment(\.dismiss) private var dismiss
    @State private var showingNameEdit = false
    @State private var showingResetConfirmation = false
    
    private var resetValue: Int {
        if let lowerLimit = session.lowerLimit, lowerLimit > 0 {
            return lowerLimit
        }
        return 0
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(session.name)
                    .font(.headline)
                Button(action: { showingNameEdit = true }) {
                    Image(systemName: "pencil.circle")
                }
            }
            .padding()
            
//            Spacer()
            
            CounterDisplayView(count: session.count, isIncrementing: isIncrementing)
            
            Spacer()
            
            CounterControlsView(
                session: $session,
                isIncrementing: $isIncrementing,
                onSave: { sessionManager.saveSession(session) }
            )
        }
        .navigationBarItems(trailing:
            Button(action: { showingResetConfirmation = true }) {
                Image(systemName: "arrow.counterclockwise")
                    .imageScale(.large)
            }
        )
        .alert("Edit Name", isPresented: $showingNameEdit) {
            TextField("Session Name", text: Binding(
                get: { session.name },
                set: { newValue in
                    session.name = newValue
                    sessionManager.saveSession(session)
                }
            ))
            Button("OK", action: { showingNameEdit = false })
            Button("Cancel", role: .cancel, action: {})
        }
        .alert("Reset Counter", isPresented: $showingResetConfirmation) {
            Button("Reset", role: .destructive) {
                if session.hapticEnabled {
                    // Double haptic feedback for reset action
                    HapticManager.shared.playHaptic(style: .decrement)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        HapticManager.shared.playHaptic(style: .decrement)
                    }
                }
                session.count = resetValue
                sessionManager.saveSession(session)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to reset the counter to \(resetValue)?")
        }
    }
}

#Preview {
    NavigationView {
        CountingStepperView(
            session: CountSession(
                count: 42,
                hapticEnabled: true,
                allowNegatives: false,
                stepSize: 1,
                upperLimit: 100,
                lowerLimit: 10
            ),
            sessionManager: CountSessionManager()
        )
    }
}
