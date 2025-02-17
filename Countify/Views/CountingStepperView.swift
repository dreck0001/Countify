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
            
            Spacer()
            
            CounterDisplayView(count: session.count, isIncrementing: isIncrementing)
            
            Spacer()
            
            CounterControlsView(
                session: $session,
                isIncrementing: $isIncrementing,
                onSave: { sessionManager.saveSession(session) }
            )
        }
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
    }
}
