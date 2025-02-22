//
//  CountingSessionView.swift
//  Countify
//
//  Created by Throw Catchers on 2/20/25.
//

import SwiftUI

// Enhanced counting view with tappable feature icons
struct CountingSessionView: View {
    @State var session: CountSession
    @ObservedObject var sessionManager: CountSessionManager
    @State private var isIncrementing = true
    @Environment(\.dismiss) private var dismiss
    @State private var showingResetConfirmation = false
    
    // State for feature-specific sheets
    @State private var showingStepSizeSheet = false
    @State private var showingLimitsSheet = false
    @State private var showingNegativesSheet = false
    @State private var showingHapticsSheet = false
    
    private var resetValue: Int {
        if let lowerLimit = session.lowerLimit, lowerLimit > 0 {
            return lowerLimit
        }
        return 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Counter Display taking up top third
            CounterDisplayView(count: session.count, isIncrementing: isIncrementing)
                .background(Color.gray)

            // Session Title
            Text(session.name)
                .font(.system(size: 28, weight: .bold))
                .padding(.bottom, 8)
            
            // Feature Tags Row - larger and tappable
            HStack(spacing: 24) {
                // Step Size Feature
                Button(action: {
                    showingStepSizeSheet = true
                }) {
                    VStack(spacing: 8) {
                        // Icon with dynamic background
                        ZStack {
                            Circle()
                                .fill(session.stepSize > 1 ?
                                      Color.blue.opacity(0.15) :
                                      Color(.systemGray5))
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(session.stepSize > 1 ? .blue : .gray)
                        }
                        
                        // Label
                        Text(session.stepSize > 1 ? "\(session.stepSize)" : "Step")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(session.stepSize > 1 ? .primary : .secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Limits Feature
                Button(action: {
                    showingLimitsSheet = true
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(session.upperLimit != nil || session.lowerLimit != nil ?
                                      Color.orange.opacity(0.15) :
                                      Color(.systemGray5))
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "ruler")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(session.upperLimit != nil || session.lowerLimit != nil ? .orange : .gray)
                        }
                        
                        Text("Limits")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(session.upperLimit != nil || session.lowerLimit != nil ? .primary : .secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Negatives Feature
                Button(action: {
                    showingNegativesSheet = true
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(session.allowNegatives ?
                                      Color.purple.opacity(0.15) :
                                      Color(.systemGray5))
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "plusminus")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(session.allowNegatives ? .purple : .gray)
                        }
                        
                        Text("Neg")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(session.allowNegatives ? .primary : .secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
                
                // Haptics Feature
                Button(action: {
                    showingHapticsSheet = true
                }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(session.hapticEnabled ?
                                      Color.green.opacity(0.15) :
                                      Color(.systemGray5))
                                .frame(width: 56, height: 56)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            
                            Image(systemName: "waveform")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(session.hapticEnabled ? .green : .gray)
                        }
                        
                        Text("Haptic")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(session.hapticEnabled ? .primary : .secondary)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(ScaleButtonStyle())
            }
            .padding(.top, 24)
            .padding(.bottom, 8)
            
            Spacer()
            
            // Counter Controls at bottom
            EnhancedCounterControlsView(
                session: $session,
                isIncrementing: $isIncrementing,
                onSave: { sessionManager.saveSession(session) }
            )
            .padding(.bottom, 30)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward.circle")
                        .font(.system(size: 24))
                        .foregroundColor(.primary)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingResetConfirmation = true
                }) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 18))
                }
            }
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
        // Step Size Sheet
        .overlay {
            if showingStepSizeSheet {
                StepSizeSheet(
                    session: $session,
                    sessionManager: sessionManager,
                    isPresented: $showingStepSizeSheet
                )
            }
        }
        // Limits Sheet
        .overlay {
            if showingLimitsSheet {
                LimitsSheet(
                    session: $session,
                    sessionManager: sessionManager,
                    isPresented: $showingLimitsSheet
                )
            }
        }
        // Negatives Sheet
        .overlay {
            if showingNegativesSheet {
                NegativesSheet(
                    session: $session,
                    sessionManager: sessionManager,
                    isPresented: $showingNegativesSheet
                )
            }
        }
        // Haptics Sheet
        .overlay {
            if showingHapticsSheet {
                HapticsSheet(
                    session: $session,
                    sessionManager: sessionManager,
                    isPresented: $showingHapticsSheet
                )
            }
        }
    }
}

// Larger, interactive feature button
struct FeatureButton: View {
    let icon: String
    let text: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            // Icon
            ZStack {
                Circle()
                    .fill(isActive ? Color.blue.opacity(0.15) : Color.primary.opacity(0.08))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isActive ? .blue : .primary.opacity(0.6))
            }
            
            // Label
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(isActive ? .blue : .primary.opacity(0.7))
        }
        .contentShape(Rectangle())
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.primary.opacity(0.1))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            
            // Title
            Text(title)
                .font(.system(size: 17))
            
            Spacer()
            
            // Value
            Text(value)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// Base sheet for all feature sheets
struct BaseActionSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let content: Content
    
    // Gesture state for dismissal
    @GestureState private var dragOffset = CGSize.zero
    @State private var offset: CGFloat = 0
    
    init(isPresented: Binding<Bool>, title: String, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent background with easy tap-to-dismiss
            // Using opacity 0.6 for better contrast
            Color.black.opacity(0.6)
                .edgesIgnoringSafeArea(.all) // More explicit about ignoring all edges
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 0) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                
                // Header
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 16)
                
                // Content
                content
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemGray6))
            )
            .offset(y: max(0, dragOffset.height) + offset)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if value.translation.height > 0 {
                            state = value.translation
                        }
                    }
                    .onEnded { value in
                        if value.translation.height > 50 {
                            dismiss()
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .transition(.move(edge: .bottom))
            // Add padding to ensure it extends beyond safe area
            .padding(.bottom, 10)
        }
        // Make sure we explicitly ignore safe areas to cover tab bar
        .edgesIgnoringSafeArea(.all)
        // Add a .statusBar modifier to ensure it covers top too
        .statusBar(hidden: false)
    }
    
    private func dismiss() {
        withAnimation(.spring()) {
            isPresented = false
        }
    }
}



// Step Size Sheet
struct StepSizeSheet: View {
    @Binding var session: CountSession
    let sessionManager: CountSessionManager
    @Binding var isPresented: Bool
    @State private var stepSize: Int
    
    init(session: Binding<CountSession>, sessionManager: CountSessionManager, isPresented: Binding<Bool>) {
        self._session = session
        self.sessionManager = sessionManager
        self._isPresented = isPresented
        self._stepSize = State(initialValue: session.wrappedValue.stepSize)
    }
    
    var body: some View {
        BaseActionSheet(isPresented: $isPresented, title: "Step Size") {
            VStack(spacing: 24) {
                // Step Size value display
                Text("\(stepSize)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                
                // Stepper
                Stepper("", value: $stepSize, in: 1...100)
                    .labelsHidden()
                    .padding(.horizontal, 60)
                
                // Common values
                HStack(spacing: 16) {
                    ForEach([1, 5, 10, 25], id: \.self) { value in
                        Button(action: {
                            stepSize = value
                        }) {
                            Text("\(value)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(stepSize == value ? .white : .primary)
                                .frame(width: 50, height: 50)
                                .background(
                                    Circle()
                                        .fill(stepSize == value ? Color.blue : Color.primary.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Save Button
                Button(action: {
                    saveStepSize()
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func saveStepSize() {
        var updatedSession = session
        updatedSession.stepSize = stepSize
        session = updatedSession
        sessionManager.saveSession(updatedSession)
        
        if session.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

// Limits Sheet
struct LimitsSheet: View {
    @Binding var session: CountSession
    let sessionManager: CountSessionManager
    @Binding var isPresented: Bool
    
    @State private var enableUpperLimit: Bool
    @State private var enableLowerLimit: Bool
    @State private var upperLimit: Int
    @State private var lowerLimit: Int
    
    init(session: Binding<CountSession>, sessionManager: CountSessionManager, isPresented: Binding<Bool>) {
        self._session = session
        self.sessionManager = sessionManager
        self._isPresented = isPresented
        
        self._enableUpperLimit = State(initialValue: session.wrappedValue.upperLimit != nil)
        self._enableLowerLimit = State(initialValue: session.wrappedValue.lowerLimit != nil)
        self._upperLimit = State(initialValue: session.wrappedValue.upperLimit ?? 100)
        self._lowerLimit = State(initialValue: session.wrappedValue.lowerLimit ?? 0)
    }
    
    var body: some View {
        BaseActionSheet(isPresented: $isPresented, title: "Counter Limits") {
            VStack(spacing: 24) {
                // Upper Limit
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Upper Limit")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Toggle("", isOn: $enableUpperLimit)
                            .labelsHidden()
                    }
                    
                    if enableUpperLimit {
                        HStack {
                            Text("\(upperLimit)")
                                .font(.system(size: 18, weight: .medium))
                            
                            Spacer()
                            
                            Stepper("", value: $upperLimit, in: (enableLowerLimit ? lowerLimit + session.stepSize : 0)...10000)
                                .labelsHidden()
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Lower Limit
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Lower Limit")
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                        
                        Toggle("", isOn: $enableLowerLimit)
                            .labelsHidden()
                    }
                    
                    if enableLowerLimit {
                        HStack {
                            Text("\(lowerLimit)")
                                .font(.system(size: 18, weight: .medium))
                            
                            Spacer()
                            
                            Stepper("", value: $lowerLimit, in: -10000...(enableUpperLimit ? upperLimit - session.stepSize : 10000))
                                .labelsHidden()
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 20)
                
                // Save Button
                Button(action: {
                    saveLimits()
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
        }
    }
    
    private func saveLimits() {
        var updatedSession = session
        updatedSession.upperLimit = enableUpperLimit ? upperLimit : nil
        updatedSession.lowerLimit = enableLowerLimit ? lowerLimit : nil
        session = updatedSession
        sessionManager.saveSession(updatedSession)
        
        if session.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

// Negatives Sheet
struct NegativesSheet: View {
    @Binding var session: CountSession
    let sessionManager: CountSessionManager
    @Binding var isPresented: Bool
    @State private var allowNegatives: Bool
    
    init(session: Binding<CountSession>, sessionManager: CountSessionManager, isPresented: Binding<Bool>) {
        self._session = session
        self.sessionManager = sessionManager
        self._isPresented = isPresented
        self._allowNegatives = State(initialValue: session.wrappedValue.allowNegatives)
    }
    
    var body: some View {
        BaseActionSheet(isPresented: $isPresented, title: "Negative Numbers") {
            VStack(spacing: 30) {
                // Toggle with description
                VStack(spacing: 16) {
                    Toggle("Allow Negative Numbers", isOn: $allowNegatives)
                        .padding(.horizontal, 20)
                    
                    Text("When enabled, the counter can go below zero")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Example visual
                HStack(spacing: 24) {
                    VStack {
                        Text("With Negatives")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.primary.opacity(0.05))
                                .frame(width: 100, height: 40)
                            
                            Text("-5")
                                .font(.system(size: 20, weight: .medium))
                        }
                    }
                    
                    VStack {
                        Text("Without Negatives")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.primary.opacity(0.05))
                                .frame(width: 100, height: 40)
                            
                            Text("0")
                                .font(.system(size: 20, weight: .medium))
                        }
                    }
                }
                .padding(.vertical, 8)
                
                // Save Button
                Button(action: {
                    saveNegatives()
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func saveNegatives() {
        var updatedSession = session
        updatedSession.allowNegatives = allowNegatives
        session = updatedSession
        sessionManager.saveSession(updatedSession)
        
        if session.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}

// Haptics Sheet
struct HapticsSheet: View {
    @Binding var session: CountSession
    let sessionManager: CountSessionManager
    @Binding var isPresented: Bool
    @State private var hapticEnabled: Bool
    
    init(session: Binding<CountSession>, sessionManager: CountSessionManager, isPresented: Binding<Bool>) {
        self._session = session
        self.sessionManager = sessionManager
        self._isPresented = isPresented
        self._hapticEnabled = State(initialValue: session.wrappedValue.hapticEnabled)
    }
    
    var body: some View {
        BaseActionSheet(isPresented: $isPresented, title: "Haptic Feedback") {
            VStack(spacing: 30) {
                // Toggle with description
                VStack(spacing: 16) {
                    Toggle("Enable Haptic Feedback", isOn: $hapticEnabled)
                        .padding(.horizontal, 20)
                    
                    Text("When enabled, you'll feel vibration patterns when incrementing, decrementing, or resetting the counter")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Haptic test buttons
                VStack(spacing: 8) {
                    Text("Test Haptics")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 20) {
                        Button(action: {
                            if hapticEnabled {
                                HapticManager.shared.playHaptic(style: .increment)
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                Text("Increment")
                                    .font(.caption)
                            }
                            .frame(width: 80, height: 60)
                            .foregroundColor(hapticEnabled ? .green : .secondary)
                        }
                        .disabled(!hapticEnabled)
                        
                        Button(action: {
                            if hapticEnabled {
                                HapticManager.shared.playHaptic(style: .decrement)
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                Text("Decrement")
                                    .font(.caption)
                            }
                            .frame(width: 80, height: 60)
                            .foregroundColor(hapticEnabled ? .red : .secondary)
                        }
                        .disabled(!hapticEnabled)
                    }
                }
                .padding(.vertical, 8)
                
                // Save Button
                Button(action: {
                    saveHaptics()
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }) {
                    Text("Save")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private func saveHaptics() {
        var updatedSession = session
        updatedSession.hapticEnabled = hapticEnabled
        session = updatedSession
        sessionManager.saveSession(updatedSession)
        
        if hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
}






#Preview {
    NavigationView {
        CountingSessionView(
            session: CountSession(
                name: "Daily Steps",
                count: 8423,
                hapticEnabled: true,
                allowNegatives: true,
                stepSize: 5,
                upperLimit: 100000,
                lowerLimit: 0
            ),
            sessionManager: CountSessionManager()
        )
    }
}
