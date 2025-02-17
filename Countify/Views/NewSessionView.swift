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
    @State private var navigateToCounter = false
    @State private var newSession: CountSession?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Session Name")) {
                    TextField("Name", text: $sessionName)
                }
                
                Section(header: Text("Session Settings")) {
                    Toggle("Vibration", isOn: $hapticEnabled)
                    Toggle("Allow Negative Numbers", isOn: $allowNegatives)
                }
            }
            .navigationTitle("New Count Session")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Start") {
                    let session = CountSession(
                        name: sessionName.isEmpty ? "New Count" : sessionName,
                        hapticEnabled: hapticEnabled,
                        allowNegatives: allowNegatives
                    )
                    sessionManager.saveSession(session)
                    newSession = session
                    navigateToCounter = true
                }
            )
            .fullScreenCover(isPresented: $navigateToCounter) {
                if let session = newSession {
                    NavigationView {
                        CountingStepperView(session: session, sessionManager: sessionManager)
                            .navigationBarItems(trailing: Button("Done") {
                                isPresented = false
                            })
                    }
                }
            }
        }
    }
}

//#Preview {
//    NewSessionView()
//}
