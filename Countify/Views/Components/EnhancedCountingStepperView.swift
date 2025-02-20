//
//  EnhancedCountingStepperView.swift
//  Countify
//
//  Created by Throw Catchers on 2/20/25.
//

import SwiftUI

// Enhanced counting view with collapsible features
struct EnhancedCountingStepperView: View {
    @State var session: CountSession
    @ObservedObject var sessionManager: CountSessionManager
    @State private var isIncrementing = true
    @State private var showingNameEdit = false
    @State private var showingResetConfirmation = false
    @State private var showFeatures = false // Controls feature visibility
    
    private var resetValue: Int {
        if let lowerLimit = session.lowerLimit, lowerLimit > 0 {
            return lowerLimit
        }
        return 0
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.95)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with session name and edit button
                HStack {
                    Text(session.name)
                        .font(.system(size: 28, weight: .bold))
                    
                    Button(action: { showingNameEdit = true }) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                
                // Collapsible feature section
                VStack {
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            showFeatures.toggle()
                        }
                    }) {
                        HStack {
                            Text("Counter Settings")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: showFeatures ? "chevron.up" : "chevron.down")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    
                    if showFeatures {
                        CollapsibleFeaturesView(session: session)
                            .transition(.move(edge: .top).combined(with: .opacity))
                            .padding(.top, 12)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Enhanced counter display
                EnhancedCounterDisplayView(count: session.count, isIncrementing: isIncrementing)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                // Enhanced counter controls
                EnhancedCounterControlsView(
                    session: $session,
                    isIncrementing: $isIncrementing,
                    onSave: { sessionManager.saveSession(session) }
                )
                .padding(.bottom, 30)
            }
            .padding()
        }
        .navigationBarItems(trailing:
            Button(action: { showingResetConfirmation = true }) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
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
            Button("Save", action: { showingNameEdit = false })
            Button("Cancel", role: .cancel, action: {})
        }
        .alert("Reset Counter", isPresented: $showingResetConfirmation) {
            Button("Reset", role: .destructive) {
                if session.hapticEnabled {
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

//#Preview {
//    EnhancedCountingStepperView()
//}
