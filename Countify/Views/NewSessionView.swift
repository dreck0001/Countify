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
    // To control focus on the name field
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Session Name")) {
                    TextField("Name your counter", text: $sessionName)
                        .focused($isNameFieldFocused)
                }
                
                Section(header: Text("Counter Settings")) {
                    Stepper("Step Size: \(stepSize)", value: $stepSize, in: 1...100)
                    Toggle("Allow Negative Numbers", isOn: $allowNegatives)
                        .onChange(of: allowNegatives) { _, newValue in
                            // If we disallow negatives, ensure lower limit is non-negative
                            if !newValue && enableLowerLimit && lowerLimit < 0 {
                                lowerLimit = 0
                            }
                        }
                    Toggle("Vibration", isOn: $hapticEnabled)
                }
                
                Section(header: Text("Limits")) {
                    Toggle("Set Upper Limit", isOn: $enableUpperLimit)
                    if enableUpperLimit {
                        Stepper("Upper Limit: \(upperLimit)", value: $upperLimit)
                    }
                    
                    Toggle("Set Lower Limit", isOn: $enableLowerLimit)
                    if enableLowerLimit {
                        // If negative numbers aren't allowed, enforce a minimum of 0
                        if !allowNegatives {
                            Stepper("Lower Limit: \(lowerLimit)", value: $lowerLimit, in: 0...Int.max)
                        } else {
                            Stepper("Lower Limit: \(lowerLimit)", value: $lowerLimit)
                        }
                    }
                }
            }
            .navigationTitle("New Counter")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createSession()
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
                        .navigationBarBackButtonHidden(true)
                        .onDisappear {
                            // When returning from CountingSessionView, dismiss the NewSessionView
                            if !navigateToCounter {
                                isPresented = false
                            }
                        }
                }
            }
            .onAppear {
                // Only set default name if it's currently empty
                if sessionName.isEmpty {
                    sessionName = generateDefaultName()
                }
                
                // Auto-focus the name field after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFieldFocused = true
                }
            }
        }
        .interactiveDismissDisabled(navigateToCounter)
    }
    
    // Function to generate a sequential default name: Counter 1, Counter 2, etc.
    private func generateDefaultName() -> String {
        // Find the highest counter number currently in use
        var highestNumber = 0
        
        for session in sessionManager.sessions {
            if session.name.hasPrefix("Counter ") {
                if let numberStr = session.name.dropFirst(8).trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: .whitespaces).first,
                   let number = Int(numberStr) {
                    highestNumber = max(highestNumber, number)
                }
            }
        }
        
        // Return the next number in sequence
        return "Counter \(highestNumber + 1)"
    }
    
    private func createSession() {
        // Use entered name or generate unique name if empty
        var finalName = sessionName.trimmingCharacters(in: .whitespacesAndNewlines)
        if finalName.isEmpty {
            finalName = generateDefaultName()
        }
        
        // Create and save the session
        let session = CountSession(
            name: finalName,
            hapticEnabled: hapticEnabled,
            allowNegatives: allowNegatives,
            stepSize: max(1, stepSize),
            upperLimit: enableUpperLimit ? upperLimit : nil,
            lowerLimit: enableLowerLimit ? lowerLimit : nil
        )
        
        sessionManager.saveSession(session)
        newSession = session
        navigateToCounter = true
        
        // Provide haptic feedback on successful creation if enabled
        if hapticEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

#Preview {
    NewSessionView(
        sessionManager: CountSessionManager(),
        isPresented: .constant(true)
    )
}
