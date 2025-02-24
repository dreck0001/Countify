//
//  NewSessionView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct NewSessionView: View {
    @ObservedObject var sessionManager: CountSessionManager
    @Binding var isPresented: Bool
    @State private var sessionName = ""
    @State private var hapticEnabled = true
    @State private var allowNegatives = false
    @State private var stepSize = 1
    @State private var enableUpperLimit = false
    @State private var enableLowerLimit = false
    @State private var upperLimit = 100
    @State private var lowerLimit = 0
    @State private var navigateToCounter = false
    @State private var newSession: CountSession?
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Session Name")) {
                    TextField("Name", text: $sessionName)
                }
                
                Section(header: Text("Counter Settings")) {
                    Stepper("Step Size: \(stepSize)", value: $stepSize, in: 1...100)
                    Toggle("Allow Negative Numbers", isOn: $allowNegatives)
                    Toggle("Vibration", isOn: $hapticEnabled)
                }
                
                Section(header: Text("Limits")) {
                    Toggle("Set Upper Limit", isOn: $enableUpperLimit)
                    if enableUpperLimit {
                        Stepper("Upper Limit: \(upperLimit)", value: $upperLimit)
                    }
                    
                    Toggle("Set Lower Limit", isOn: $enableLowerLimit)
                    if enableLowerLimit {
                        Stepper("Lower Limit: \(lowerLimit)", value: $lowerLimit)
                    }
                }
            }
            .navigationTitle("New Count Session")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        let session = CountSession(
                            name: sessionName.isEmpty ? "New Count" : sessionName,
                            hapticEnabled: hapticEnabled,
                            allowNegatives: allowNegatives,
                            stepSize: max(1, stepSize),  // Ensure step size is at least 1
                            upperLimit: enableUpperLimit ? upperLimit : nil,
                            lowerLimit: enableLowerLimit ? lowerLimit : nil
                        )
                        sessionManager.saveSession(session)
                        newSession = session
                        navigateToCounter = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToCounter) {
                if let session = newSession {
                    CountingSessionView(session: session, sessionManager: sessionManager)
                        .onDisappear {
                            // When returning from CountingSessionView, dismiss the NewSessionView
                            if !navigateToCounter {
                                isPresented = false
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    NewSessionView(
        sessionManager: CountSessionManager(),
        isPresented: .constant(true)
    )
}
