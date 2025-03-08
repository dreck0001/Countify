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
    @State private var showingDeleteConfirmation = false
    
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
            Divider()
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
                            
                            Image(systemName: "hand.tap")
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
            .padding(.top, 20)
            .padding(.bottom, 20)
            Divider()
            Spacer()
            
            // Counter Controls at bottom
            EnhancedCounterControlsView(
                session: $session,
                isIncrementing: $isIncrementing,
                onSave: { sessionManager.saveSession(session) }
            )
            .padding(.bottom, 30)
        }
        .navigationTitle(session.name)
        .toolbarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingResetConfirmation = true
                    }) {
                        Label("Reset Counter", systemImage: "arrow.counterclockwise")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteConfirmation = true
                    }) {
                        Label("Delete Counter", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20))
                }
            }
        }        .alert("Reset Counter", isPresented: $showingResetConfirmation) {
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
        .alert("Delete Counter", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let index = sessionManager.sessions.firstIndex(where: { $0.id == session.id }) {
                    sessionManager.deleteSession(at: IndexSet(integer: index))
                    if session.hapticEnabled {
                        HapticManager.shared.playHaptic(style: .decrement)
                    }
                    dismiss()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this counter? This action cannot be undone.")
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
                // Drag indicator - Instagram style
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.5))
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
                ZStack {
                    // Instagram-style background
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground).opacity(0.98))
                    
                    // Simple edge stroke - Instagram style
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                }
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
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


// MARK: - StepSizeSheet
struct StepSizeSheet: View {
    @Binding var session: CountSession
    let sessionManager: CountSessionManager
    @Binding var isPresented: Bool
    @State private var stepSize: Int
    @State private var stepSizeString: String
    @FocusState private var isTextFieldFocused: Bool
    
    init(session: Binding<CountSession>, sessionManager: CountSessionManager, isPresented: Binding<Bool>) {
        self._session = session
        self.sessionManager = sessionManager
        self._isPresented = isPresented
        self._stepSize = State(initialValue: session.wrappedValue.stepSize)
        self._stepSizeString = State(initialValue: "\(session.wrappedValue.stepSize)")
    }
    
    var body: some View {
        ModernActionSheet(isPresented: $isPresented, title: "Step Size") {
            VStack(spacing: 16) {
                // Combined input with stepper buttons
                HStack(spacing: 20) {
                    // Decrement button - made larger
                    Button(action: {
                        if stepSize > 1 {
                            stepSize -= 1
                            stepSizeString = "\(stepSize)"
                            hapticFeedback()
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(stepSize > 1 ? .primary : .gray)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color.primary.opacity(0.05))
                            )
                    }
                    .disabled(stepSize <= 1)
                    
                    // Text field centered between buttons
                    TextField("1-100", text: $stepSizeString)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .frame(width: 80)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.primary.opacity(0.05))
                        )
                        .focused($isTextFieldFocused)
                        .onChange(of: stepSizeString) { oldValue, newValue in
                            // Filter non-numeric characters
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                stepSizeString = filtered
                            }
                            
                            // Update stepSize if valid
                            if let value = Int(filtered), value >= 1, value <= 100 {
                                stepSize = value
                            } else if filtered.isEmpty {
                                // Allow empty field while typing
                            } else {
                                // Revert to valid value if invalid
                                stepSizeString = "\(stepSize)"
                            }
                        }
                    
                    // Increment button - made larger
                    Button(action: {
                        if stepSize < 100 {
                            stepSize += 1
                            stepSizeString = "\(stepSize)"
                            hapticFeedback()
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(stepSize < 100 ? .primary : .gray)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(Color.primary.opacity(0.05))
                            )
                    }
                    .disabled(stepSize >= 100)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .onDisappear {
                saveStepSize()
            }
            .onTapGesture {
                // Dismiss keyboard when tapping outside
                isTextFieldFocused = false
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextFieldFocused = false
                }
            }
        }
    }
    
    private func saveStepSize() {
        // Only save and trigger haptic feedback if the value actually changed
        if session.stepSize != stepSize {
            var updatedSession = session
            updatedSession.stepSize = stepSize
            session = updatedSession
            sessionManager.saveSession(updatedSession)
            
            if session.hapticEnabled {
                let generator = UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(.success)
            }
        }
    }
    
    private func hapticFeedback() {
        if session.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.6)
        }
    }
}

// MARK: - LimitsSheet (Simplified)
struct LimitsSheet: View {
    @Binding var session: CountSession
    let sessionManager: CountSessionManager
    @Binding var isPresented: Bool
    
    @State private var enableUpperLimit: Bool
    @State private var enableLowerLimit: Bool
    @State private var upperLimit: Int
    @State private var lowerLimit: Int
    @State private var upperLimitString: String
    @State private var lowerLimitString: String
    
    // Focus states for text fields
    @FocusState private var isUpperLimitFocused: Bool
    @FocusState private var isLowerLimitFocused: Bool
    
    init(session: Binding<CountSession>, sessionManager: CountSessionManager, isPresented: Binding<Bool>) {
        self._session = session
        self.sessionManager = sessionManager
        self._isPresented = isPresented
        
        self._enableUpperLimit = State(initialValue: session.wrappedValue.upperLimit != nil)
        self._enableLowerLimit = State(initialValue: session.wrappedValue.lowerLimit != nil)
        self._upperLimit = State(initialValue: session.wrappedValue.upperLimit ?? 100)
        self._lowerLimit = State(initialValue: session.wrappedValue.lowerLimit ?? 0)
        self._upperLimitString = State(initialValue: "\(session.wrappedValue.upperLimit ?? 100)")
        self._lowerLimitString = State(initialValue: "\(session.wrappedValue.lowerLimit ?? 0)")
    }
    
    var body: some View {
        ModernActionSheet(isPresented: $isPresented, title: "Counter Limits") {
            VStack(spacing: 24) {
                // Upper Limit
                VStack(alignment: .leading, spacing: 10) {
                    ModernToggle(title: "Upper Limit", isOn: $enableUpperLimit)
                    
                    if enableUpperLimit {
                        // Direct text input with simple stepper buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                decrementUpperLimit()
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                            }
                            .disabled(!enableUpperLimit)
                            
                            Spacer()
                            
                            // Text field for direct input
                            TextField("Max", text: $upperLimitString)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .frame(width: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.1))
                                )
                                .disabled(!enableUpperLimit)
                                .focused($isUpperLimitFocused)
                                .onChange(of: upperLimitString) { oldValue, newValue in
                                    // Filter non-numeric characters
                                    let filtered = newValue.filter { "0123456789".contains($0) }
                                    if filtered != newValue {
                                        upperLimitString = filtered
                                    }
                                    
                                    // Update upper limit if valid
                                    if let value = Int(filtered) {
                                        upperLimit = value
                                        
                                        // Ensure lower limit stays below upper limit
                                        if enableLowerLimit && lowerLimit >= upperLimit {
                                            if upperLimit > session.stepSize {
                                                lowerLimit = upperLimit - session.stepSize
                                                lowerLimitString = "\(lowerLimit)"
                                            }
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                            Button(action: {
                                incrementUpperLimit()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                            }
                            .disabled(!enableUpperLimit)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Lower Limit
                VStack(alignment: .leading, spacing: 10) {
                    ModernToggle(title: "Lower Limit", isOn: $enableLowerLimit)
                    
                    if enableLowerLimit {
                        // Direct text input with simple stepper buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                decrementLowerLimit()
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                            }
                            .disabled(!enableLowerLimit || (!session.allowNegatives && lowerLimit <= 0))
                            
                            Spacer()
                            
                            // Text field for direct input
                            TextField("Min", text: $lowerLimitString)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .frame(width: 100)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.1))
                                )
                                .disabled(!enableLowerLimit)
                                .focused($isLowerLimitFocused)
                                .onChange(of: lowerLimitString) { oldValue, newValue in
                                    // Filter non-numeric characters and handle negative sign
                                    var filtered = newValue
                                    if filtered.first == "-" {
                                        // Only allow negative sign if negatives are permitted
                                        if session.allowNegatives {
                                            filtered.removeFirst()
                                            filtered = "-" + filtered.filter { "0123456789".contains($0) }
                                        } else {
                                            filtered = filtered.filter { "0123456789".contains($0) }
                                        }
                                    } else {
                                        filtered = filtered.filter { "0123456789".contains($0) }
                                    }
                                    
                                    if filtered != newValue {
                                        lowerLimitString = filtered
                                    }
                                    
                                    // Update lower limit if valid
                                    if let value = Int(filtered) {
                                        // Enforce non-negative if negatives aren't allowed
                                        if !session.allowNegatives && value < 0 {
                                            lowerLimit = 0
                                            lowerLimitString = "0"
                                        } else {
                                            lowerLimit = value
                                        }
                                        
                                        // Ensure upper limit stays above lower limit
                                        if enableUpperLimit && upperLimit <= lowerLimit {
                                            upperLimit = lowerLimit + session.stepSize
                                            upperLimitString = "\(upperLimit)"
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                            Button(action: {
                                incrementLowerLimit()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                                    .background(
                                        Circle()
                                            .fill(Color.orange.opacity(0.1))
                                    )
                            }
                            .disabled(!enableLowerLimit)
                        }
                        .padding(.vertical, 6)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .onDisappear {
                saveLimits()
            }
            .onTapGesture {
                // Dismiss keyboard when tapping outside
                isUpperLimitFocused = false
                isLowerLimitFocused = false
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isUpperLimitFocused = false
                    isLowerLimitFocused = false
                }
            }
        }
    }
    
    // MARK: - Value Change Functions
    
    private func incrementUpperLimit() {
        upperLimit += 1
        upperLimitString = "\(upperLimit)"
        
        // Ensure lower limit stays below upper limit
        if enableLowerLimit && lowerLimit >= upperLimit {
            lowerLimit = upperLimit - session.stepSize
            lowerLimitString = "\(lowerLimit)"
        }
        
        hapticFeedback()
    }
    
    private func decrementUpperLimit() {
        // Ensure it stays above lower limit + step size if lower limit is enabled
        let minValue = enableLowerLimit ? lowerLimit + session.stepSize : session.stepSize
        
        if upperLimit > minValue {
            upperLimit -= 1
            upperLimit = max(minValue, upperLimit)
            upperLimitString = "\(upperLimit)"
            hapticFeedback()
        }
    }
    
    private func incrementLowerLimit() {
        // Ensure it stays below upper limit - step size if upper limit is enabled
        let maxValue = enableUpperLimit ? upperLimit - session.stepSize : Int.max
        
        if lowerLimit < maxValue {
            lowerLimit += 1
            lowerLimit = min(maxValue, lowerLimit)
            lowerLimitString = "\(lowerLimit)"
            hapticFeedback()
        }
    }
    
    private func decrementLowerLimit() {
        // Don't allow going below 0 if negatives are not allowed
        if !session.allowNegatives && lowerLimit - 1 < 0 {
            return
        }
        
        lowerLimit -= 1
        lowerLimitString = "\(lowerLimit)"
        hapticFeedback()
    }
    
    private func saveLimits() {
        // Get final values from inputs
        let finalUpperLimit = enableUpperLimit ? (Int(upperLimitString) ?? upperLimit) : nil
        let finalLowerLimit = enableLowerLimit ? (Int(lowerLimitString) ?? lowerLimit) : nil
        
        // Check if there are actual changes to save
        let limitsChanged = (finalUpperLimit != session.upperLimit) ||
                            (finalLowerLimit != session.lowerLimit)
        
        if limitsChanged {
            var updatedSession = session
            
            // If negatives aren't allowed, ensure lower limit is non-negative
            if !session.allowNegatives && finalLowerLimit != nil && finalLowerLimit! < 0 {
                updatedSession.lowerLimit = 0
            } else {
                updatedSession.lowerLimit = finalLowerLimit
            }
            
            updatedSession.upperLimit = finalUpperLimit
            
            // Adjust count if needed to respect the new limits
            if let lowerLimit = updatedSession.lowerLimit, updatedSession.count < lowerLimit {
                updatedSession.count = lowerLimit
            } else if let upperLimit = finalUpperLimit, updatedSession.count > upperLimit {
                updatedSession.count = upperLimit
            }
            
            session = updatedSession
            sessionManager.saveSession(updatedSession)
            
            if session.hapticEnabled {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
    
    private func hapticFeedback() {
        if session.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.6)
        }
    }
}

// MARK: - NegativesSheet (Simplified)
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
        ModernActionSheet(isPresented: $isPresented, title: "Negative Numbers") {
            VStack(spacing: 16) {
                // Toggle with concise description
                VStack(spacing: 8) {
                    ModernToggle(title: "Allow Negative Numbers", isOn: $allowNegatives)
                    
                    Text("When enabled, the counter can go below zero")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .onDisappear {
                saveNegatives()
            }
        }
    }
    
    private func saveNegatives() {
        // Only save and provide feedback if the setting changed
        if session.allowNegatives != allowNegatives {
            var updatedSession = session
            updatedSession.allowNegatives = allowNegatives
            
            // If negatives are disabled and a lower limit is set, update the lower limit
            if !allowNegatives && updatedSession.lowerLimit != nil && updatedSession.lowerLimit! < 0 {
                updatedSession.lowerLimit = 0
            }
            
            // If negatives are disabled and count is negative, adjust count to 0 or lower limit
            if !allowNegatives && updatedSession.count < 0 {
                if let lowerLimit = updatedSession.lowerLimit, lowerLimit >= 0 {
                    updatedSession.count = lowerLimit
                } else {
                    updatedSession.count = 0
                }
            }
            
            session = updatedSession
            sessionManager.saveSession(updatedSession)
            
            if session.hapticEnabled {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
}

// MARK: - HapticsSheet (Simplified)
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
        ModernActionSheet(isPresented: $isPresented, title: "Haptic Feedback") {
            VStack(spacing: 16) {
                // Toggle with description
                VStack(spacing: 8) {
                    ModernToggle(title: "Enable Haptic Feedback", isOn: $hapticEnabled)
                    
                    Text("When enabled, you'll feel vibration patterns when incrementing, decrementing, or resetting the counter")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            .onDisappear {
                saveHaptics()
            }
        }
    }
    
    private func saveHaptics() {
        // Only save and provide feedback if the setting changed
        if session.hapticEnabled != hapticEnabled {
            var updatedSession = session
            updatedSession.hapticEnabled = hapticEnabled
            session = updatedSession
            sessionManager.saveSession(updatedSession)
            
            // Only provide haptic feedback if haptic is being enabled (not when disabled)
            if hapticEnabled {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
    }
}

// MARK: - Supporting Components
struct FeedbackTypeCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isEnabled: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(isEnabled ? color : .gray)
                
                Spacer()
                
                Image(systemName: "hand.tap")
                    .font(.system(size: 12))
                    .foregroundColor(isEnabled ? color.opacity(0.8) : .gray.opacity(0.5))
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isEnabled ? .primary : .secondary)
            
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(isEnabled ? .secondary : .secondary.opacity(0.7))
        }
        .padding(12)
        .frame(height: 100)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isEnabled ? color.opacity(0.1) : Color.gray.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(isEnabled ? color.opacity(0.2) : Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}




#Preview {
    NavigationView {
        CountingSessionView(
            session: CountSession(
                name: "Daily Steps",
                count: 12345,
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
