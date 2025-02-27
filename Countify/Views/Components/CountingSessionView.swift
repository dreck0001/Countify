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
        .swipeToGoBack(dismiss: dismiss)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
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
                        .foregroundColor(.primary)
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



// MARK: - StepSizeSheet
struct StepSizeSheet: View {
    @Binding var session: CountSession
    let sessionManager: CountSessionManager
    @Binding var isPresented: Bool
    @State private var stepSize: Int
    @State private var stepSizeString: String
    @FocusState private var isTextFieldFocused: Bool
    
    // States for handling long press
    @State private var isLongPressingIncrement = false
    @State private var isLongPressingDecrement = false
    @State private var changeRate = 1  // Will increase over time for faster scrolling
    @State private var longPressTimer: Timer?
    
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
                // Direct text input for step size
                HStack {
                    Text("Step Value:")
                        .font(.system(size: 16, weight: .medium))
                    
                    Spacer()
                    
                    // Text field allows direct entry of numbers
                    TextField("1-100", text: $stepSizeString)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
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
                }
                .padding(.horizontal, 20)
                
                // Mini stepper buttons with long press functionality
                HStack {
                    // Decrement button with long press
                    Button(action: {
                        // Single tap action
                        decrementStepSize()
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(stepSize > 1 ? .primary : .gray)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(isLongPressingDecrement ? Color.primary.opacity(0.1) : Color.primary.opacity(0.05))
                            )
                            .scaleEffect(isLongPressingDecrement ? 0.9 : 1.0)
                    }
                    .disabled(stepSize <= 1)
                    // Long press gesture
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                // Start long press
                                isLongPressingDecrement = true
                                startDecrementTimer()
                                hapticFeedback()
                            }
                    )
                    // Detect when press ends
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { _ in
                                if isLongPressingDecrement {
                                    stopTimers()
                                }
                            }
                    )
                    
                    Spacer()
                    
                    // Increment button with long press
                    Button(action: {
                        // Single tap action
                        incrementStepSize()
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(stepSize < 100 ? .primary : .gray)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(isLongPressingIncrement ? Color.primary.opacity(0.1) : Color.primary.opacity(0.05))
                            )
                            .scaleEffect(isLongPressingIncrement ? 0.9 : 1.0)
                    }
                    .disabled(stepSize >= 100)
                    // Long press gesture
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration: 0.5)
                            .onEnded { _ in
                                // Start long press
                                isLongPressingIncrement = true
                                startIncrementTimer()
                                hapticFeedback()
                            }
                    )
                    // Detect when press ends
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded { _ in
                                if isLongPressingIncrement {
                                    stopTimers()
                                }
                            }
                    )
                }
                .padding(.horizontal, 40)
                .animation(.easeInOut(duration: 0.2), value: isLongPressingDecrement)
                .animation(.easeInOut(duration: 0.2), value: isLongPressingIncrement)
                
                Divider()
                    .padding(.vertical, 4)
                
                // Common values - more compact layout
                Text("Common Values")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                
                // Common values in grid layout to save space
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach([1, 5, 10, 25, 50, 75, 100], id: \.self) { value in
                        Button(action: {
                            stepSize = value
                            stepSizeString = "\(value)"
                            hapticFeedback()
                        }) {
                            Text("\(value)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(stepSize == value ? .white : .primary)
                                .frame(height: 36)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(stepSize == value ? Color.blue : Color.primary.opacity(0.05))
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                // Save Button
                ModernActionButton(text: "Save", action: {
                    // Ensure value is valid before saving
                    if let value = Int(stepSizeString), value >= 1, value <= 100 {
                        stepSize = value
                    } else {
                        stepSize = max(1, min(100, stepSize))
                        stepSizeString = "\(stepSize)"
                    }
                    
                    saveStepSize()
                    isTextFieldFocused = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                })
                .padding(.top, 16)
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 20)
            // Dismiss keyboard when tapping outside the text field
            .onTapGesture {
                isTextFieldFocused = false
            }
            // Make sure to cancel timers when view disappears
            .onDisappear {
                stopTimers()
            }
        }
        // Add toolbar with Done button for numeric keyboard
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTextFieldFocused = false
                }
            }
        }
    }
    
    // MARK: - Timer Functions for Continuous Change
    
    private func startIncrementTimer() {
        // Cancel any existing timer
        longPressTimer?.invalidate()
        
        // Reset change rate
        changeRate = 1
        
        // Create a new timer that fires repeatedly
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            incrementStepSize()
            
            // Increase change rate over time
            if timer.timeInterval > 1.0 {
                changeRate = min(changeRate + 1, 5)
            }
        }
    }
    
    private func startDecrementTimer() {
        // Cancel any existing timer
        longPressTimer?.invalidate()
        
        // Reset change rate
        changeRate = 1
        
        // Create a new timer that fires repeatedly
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            decrementStepSize()
            
            // Increase change rate over time
            if timer.timeInterval > 1.0 {
                changeRate = min(changeRate + 1, 5)
            }
        }
    }
    
    private func stopTimers() {
        longPressTimer?.invalidate()
        longPressTimer = nil
        isLongPressingIncrement = false
        isLongPressingDecrement = false
        changeRate = 1
    }
    
    // MARK: - Value Change Functions
    
    private func incrementStepSize() {
        if stepSize < 100 {
            // Apply change rate for faster scrolling
            stepSize = min(100, stepSize + changeRate)
            stepSizeString = "\(stepSize)"
            
            // Lighter haptic for continuous change
            if session.hapticEnabled && changeRate == 1 {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred(intensity: 0.3)
            }
        } else {
            stopTimers()
        }
    }
    
    private func decrementStepSize() {
        if stepSize > 1 {
            // Apply change rate for faster scrolling
            stepSize = max(1, stepSize - changeRate)
            stepSizeString = "\(stepSize)"
            
            // Lighter haptic for continuous change
            if session.hapticEnabled && changeRate == 1 {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred(intensity: 0.3)
            }
        } else {
            stopTimers()
        }
    }
    
    private func saveStepSize() {
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
    
    private func hapticFeedback() {
        if session.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.6)
        }
    }
}

// MARK: - LimitsSheet
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
    
    // States for handling long press
    @State private var isLongPressingUpperIncrement = false
    @State private var isLongPressingUpperDecrement = false
    @State private var isLongPressingLowerIncrement = false
    @State private var isLongPressingLowerDecrement = false
    @State private var changeRate = 1  // Will increase over time for faster scrolling
    @State private var longPressTimer: Timer?
    
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
                        // Direct text input with continuous stepper buttons
                        HStack {
                            // Decrement button
                            Button(action: {
                                decrementUpperLimit()
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(isLongPressingUpperDecrement ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                                    )
                                    .scaleEffect(isLongPressingUpperDecrement ? 0.9 : 1.0)
                            }
                            .disabled(!enableUpperLimit)
                            // Long press gesture
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        isLongPressingUpperDecrement = true
                                        startUpperDecrementTimer()
                                        hapticFeedback()
                                    }
                            )
                            // Detect when press ends
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { _ in
                                        if isLongPressingUpperDecrement {
                                            stopTimers()
                                        }
                                    }
                            )
                            
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
                            
                            // Increment button
                            Button(action: {
                                incrementUpperLimit()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(isLongPressingUpperIncrement ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                                    )
                                    .scaleEffect(isLongPressingUpperIncrement ? 0.9 : 1.0)
                            }
                            .disabled(!enableUpperLimit)
                            // Long press gesture
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        isLongPressingUpperIncrement = true
                                        startUpperIncrementTimer()
                                        hapticFeedback()
                                    }
                            )
                            // Detect when press ends
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { _ in
                                        if isLongPressingUpperIncrement {
                                            stopTimers()
                                        }
                                    }
                            )
                        }
                        .padding(.vertical, 6)
                        .animation(.easeInOut(duration: 0.2), value: isLongPressingUpperDecrement)
                        .animation(.easeInOut(duration: 0.2), value: isLongPressingUpperIncrement)
                        
                        // Visual indicator for the upper limit
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange.opacity(0.1))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: 200 * (min(CGFloat(upperLimit), 1000) / 1000), height: 6)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                // Lower Limit
                VStack(alignment: .leading, spacing: 10) {
                    ModernToggle(title: "Lower Limit", isOn: $enableLowerLimit)
                    
                    if enableLowerLimit {
                        // Direct text input with continuous stepper buttons
                        HStack {
                            // Decrement button
                            Button(action: {
                                decrementLowerLimit()
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(isLongPressingLowerDecrement ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                                    )
                                    .scaleEffect(isLongPressingLowerDecrement ? 0.9 : 1.0)
                            }
                            .disabled(!enableLowerLimit)
                            // Long press gesture
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        isLongPressingLowerDecrement = true
                                        startLowerDecrementTimer()
                                        hapticFeedback()
                                    }
                            )
                            // Detect when press ends
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { _ in
                                        if isLongPressingLowerDecrement {
                                            stopTimers()
                                        }
                                    }
                            )
                            
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
                                        filtered.removeFirst()
                                        filtered = "-" + filtered.filter { "0123456789".contains($0) }
                                    } else {
                                        filtered = filtered.filter { "0123456789".contains($0) }
                                    }
                                    
                                    if filtered != newValue {
                                        lowerLimitString = filtered
                                    }
                                    
                                    // Update lower limit if valid
                                    if let value = Int(filtered) {
                                        lowerLimit = value
                                        
                                        // Ensure upper limit stays above lower limit
                                        if enableUpperLimit && upperLimit <= lowerLimit {
                                            upperLimit = lowerLimit + session.stepSize
                                            upperLimitString = "\(upperLimit)"
                                        }
                                    }
                                }
                            
                            Spacer()
                            
                            // Increment button
                            Button(action: {
                                incrementLowerLimit()
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.primary)
                                    .frame(width: 32, height: 32)
                                    .background(
                                        Circle()
                                            .fill(isLongPressingLowerIncrement ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                                    )
                                    .scaleEffect(isLongPressingLowerIncrement ? 0.9 : 1.0)
                            }
                            .disabled(!enableLowerLimit)
                            // Long press gesture
                            .simultaneousGesture(
                                LongPressGesture(minimumDuration: 0.5)
                                    .onEnded { _ in
                                        isLongPressingLowerIncrement = true
                                        startLowerIncrementTimer()
                                        hapticFeedback()
                                    }
                            )
                            // Detect when press ends
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { _ in
                                        if isLongPressingLowerIncrement {
                                            stopTimers()
                                        }
                                    }
                            )
                        }
                        .padding(.vertical, 6)
                        .animation(.easeInOut(duration: 0.2), value: isLongPressingLowerDecrement)
                        .animation(.easeInOut(duration: 0.2), value: isLongPressingLowerIncrement)
                        
                        // Visual indicator for the lower limit
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange.opacity(0.1))
                                .frame(height: 6)
                            
                            let normalizedValue = CGFloat(lowerLimit + 10000) / 20000
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: 200 * normalizedValue, height: 6)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal, 20)
                
                // Visual representation of range when both limits are enabled
                if enableUpperLimit && enableLowerLimit {
                    VStack(spacing: 6) {
                        Text("Valid Range")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.orange.opacity(0.15))
                                .frame(height: 60)
                            
                            HStack(spacing: 0) {
                                Text("\(lowerLimit)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding(.leading, 16)
                                
                                Spacer()
                                
                                Text("\(upperLimit)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding(.trailing, 16)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                // Common presets for quick selection
                if enableUpperLimit || enableLowerLimit {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Common Presets")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                // Common upper limit presets
                                if enableUpperLimit {
                                    Group {
                                        limitPresetButton(value: 10, isSelected: upperLimit == 10, action: {
                                            upperLimit = 10
                                            upperLimitString = "10"
                                        })
                                        
                                        limitPresetButton(value: 50, isSelected: upperLimit == 50, action: {
                                            upperLimit = 50
                                            upperLimitString = "50"
                                        })
                                        
                                        limitPresetButton(value: 100, isSelected: upperLimit == 100, action: {
                                            upperLimit = 100
                                            upperLimitString = "100"
                                        })
                                        
                                        limitPresetButton(value: 1000, isSelected: upperLimit == 1000, action: {
                                            upperLimit = 1000
                                            upperLimitString = "1000"
                                        })
                                    }
                                }
                                
                                // Common lower limit presets
                                if enableLowerLimit {
                                    Group {
                                        limitPresetButton(value: 0, isSelected: lowerLimit == 0, action: {
                                            lowerLimit = 0
                                            lowerLimitString = "0"
                                        })
                                        
                                        limitPresetButton(value: 1, isSelected: lowerLimit == 1, action: {
                                            lowerLimit = 1
                                            lowerLimitString = "1"
                                        })
                                        
                                        limitPresetButton(value: 10, isSelected: lowerLimit == 10, action: {
                                            lowerLimit = 10
                                            lowerLimitString = "10"
                                        })
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 10)
                }
                
                // Save Button
                ModernActionButton(text: "Save", action: {
                    saveLimits()
                    // Clear focus from text fields
                    isUpperLimitFocused = false
                    isLowerLimitFocused = false
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                })
                .padding(.top, 20)
                .padding(.horizontal, 20)
            }
            .onTapGesture {
                // Dismiss keyboard when tapping outside
                isUpperLimitFocused = false
                isLowerLimitFocused = false
            }
            .onDisappear {
                stopTimers()
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
    
    // MARK: - Custom Components
    
    private func limitPresetButton(value: Int, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            hapticFeedback()
        }) {
            Text("\(value)")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(height: 36)
                .frame(minWidth: 60)
                .padding(.horizontal, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.orange : Color.primary.opacity(0.05))
                )
        }
    }
    
    // MARK: - Timer Functions for Continuous Change
    
    // Upper limit increment timer
    private func startUpperIncrementTimer() {
        longPressTimer?.invalidate()
        changeRate = 1
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            incrementUpperLimit()
            
            // Increase change rate over time
            if timer.timeInterval > 0.5 {
                changeRate = min(changeRate + 1, 10)
            }
        }
    }
    
    // Upper limit decrement timer
    private func startUpperDecrementTimer() {
        longPressTimer?.invalidate()
        changeRate = 1
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            decrementUpperLimit()
            
            // Increase change rate over time
            if timer.timeInterval > 0.5 {
                changeRate = min(changeRate + 1, 10)
            }
        }
    }
    
    // Lower limit increment timer
    private func startLowerIncrementTimer() {
        longPressTimer?.invalidate()
        changeRate = 1
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            incrementLowerLimit()
            
            // Increase change rate over time
            if timer.timeInterval > 0.5 {
                changeRate = min(changeRate + 1, 10)
            }
        }
    }
    
    // Lower limit decrement timer
    private func startLowerDecrementTimer() {
        longPressTimer?.invalidate()
        changeRate = 1
        
        longPressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            decrementLowerLimit()
            
            // Increase change rate over time
            if timer.timeInterval > 0.5 {
                changeRate = min(changeRate + 1, 10)
            }
        }
    }
    
    private func stopTimers() {
        longPressTimer?.invalidate()
        longPressTimer = nil
        isLongPressingUpperIncrement = false
        isLongPressingUpperDecrement = false
        isLongPressingLowerIncrement = false
        isLongPressingLowerDecrement = false
        changeRate = 1
    }
    
    // MARK: - Value Change Functions
    
    private func incrementUpperLimit() {
        upperLimit += changeRate
        upperLimitString = "\(upperLimit)"
        
        // Ensure lower limit stays below upper limit
        if enableLowerLimit && lowerLimit >= upperLimit {
            lowerLimit = upperLimit - session.stepSize
            lowerLimitString = "\(lowerLimit)"
        }
        
        // Lighter haptic for continuous change
        if session.hapticEnabled && changeRate == 1 {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.3)
        }
    }
    
    private func decrementUpperLimit() {
        // Ensure it stays above lower limit + step size if lower limit is enabled
        let minValue = enableLowerLimit ? lowerLimit + session.stepSize : session.stepSize
        
        if upperLimit > minValue {
            upperLimit -= changeRate
            upperLimit = max(minValue, upperLimit)
            upperLimitString = "\(upperLimit)"
            
            // Lighter haptic for continuous change
            if session.hapticEnabled && changeRate == 1 {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred(intensity: 0.3)
            }
        }
    }
    
    private func incrementLowerLimit() {
        // Ensure it stays below upper limit - step size if upper limit is enabled
        let maxValue = enableUpperLimit ? upperLimit - session.stepSize : Int.max
        
        if lowerLimit < maxValue {
            lowerLimit += changeRate
            lowerLimit = min(maxValue, lowerLimit)
            lowerLimitString = "\(lowerLimit)"
            
            // Lighter haptic for continuous change
            if session.hapticEnabled && changeRate == 1 {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred(intensity: 0.3)
            }
        }
    }
    
    private func decrementLowerLimit() {
        lowerLimit -= changeRate
        lowerLimitString = "\(lowerLimit)"
        
        // Lighter haptic for continuous change
        if session.hapticEnabled && changeRate == 1 {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.3)
        }
    }
    
    private func saveLimits() {
        // Validate and convert text input to integers
        let finalUpperLimit = enableUpperLimit ? (Int(upperLimitString) ?? upperLimit) : nil
        let finalLowerLimit = enableLowerLimit ? (Int(lowerLimitString) ?? lowerLimit) : nil
        
        var updatedSession = session
        updatedSession.upperLimit = finalUpperLimit
        updatedSession.lowerLimit = finalLowerLimit
        
        // Adjust count if needed to respect the new limits
        if let lowerLimit = finalLowerLimit, updatedSession.count < lowerLimit {
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
    
    private func hapticFeedback() {
        if session.hapticEnabled {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred(intensity: 0.6)
        }
    }
}


// MARK: - NegativesSheet
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
                }
                .padding(.horizontal, 20)
                
                // Interactive comparison example
                HStack(spacing: 16) {
                    // Without negatives example
                    VStack(spacing: 6) {
                        Text("Without Negatives")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Counter display
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(!allowNegatives ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                                    .frame(height: 40)
                                
                                Text("0")
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .foregroundColor(!allowNegatives ? .primary : .secondary)
                            }
                            
                            // Disabled minus button visualization
                            HStack {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 18))
                                
                                Text("Disabled")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(!allowNegatives ? Color.primary.opacity(0.03) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(!allowNegatives ? Color.blue.opacity(0.2) : Color.clear, lineWidth: 1)
                    )
                    
                    // With negatives example
                    VStack(spacing: 6) {
                        Text("With Negatives")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // Counter display
                        VStack(spacing: 4) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(allowNegatives ? Color.purple.opacity(0.1) : Color.gray.opacity(0.1))
                                    .frame(height: 40)
                                
                                HStack(spacing: 2) {
                                    Text("-5")
                                        .font(.system(size: 20, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(allowNegatives ? .primary : .secondary)
                            }
                            
                            // Active minus button visualization
                            HStack {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(allowNegatives ? .purple : .gray)
                                    .font(.system(size: 18))
                                
                                Text("Active")
                                    .font(.system(size: 12))
                                    .foregroundColor(allowNegatives ? .purple : .gray)
                            }
                            .padding(.top, 2)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(allowNegatives ? Color.primary.opacity(0.03) : Color.clear)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(allowNegatives ? Color.purple.opacity(0.2) : Color.clear, lineWidth: 1)
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                
                // Save Button
                ModernActionButton(text: "Save", action: {
                    saveNegatives()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                })
                .padding(.top, 12)
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
        }
    }
    
    private func saveNegatives() {
        var updatedSession = session
        updatedSession.allowNegatives = allowNegatives
        
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
// MARK: - HapticsSheet
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
            VStack(spacing: 30) {
                // Toggle with description
                VStack(spacing: 16) {
                    ModernToggle(title: "Enable Haptic Feedback", isOn: $hapticEnabled)
                    
                    Text("When enabled, you'll feel vibration patterns when incrementing, decrementing, or resetting the counter")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Illustrated guide with improved visuals
                VStack(spacing: 16) {
                    Text("Different Actions, Different Feels")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 20) {
                        FeedbackTypeCard(
                            icon: "arrow.up",
                            title: "Increment",
                            description: "Single tap",
                            color: .green,
                            isEnabled: hapticEnabled
                        )
                        
                        FeedbackTypeCard(
                            icon: "arrow.down",
                            title: "Decrement",
                            description: "Double tap",
                            color: .red,
                            isEnabled: hapticEnabled
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Haptic test buttons
                VStack(spacing: 10) {
                    Text("Test Haptics")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 30) {
                        Button(action: {
                            if hapticEnabled {
                                HapticManager.shared.playHaptic(style: .increment)
                            }
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(hapticEnabled ? Color.green.opacity(0.15) : Color.gray.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(hapticEnabled ? .green : .gray)
                                }
                                
                                Text("Increment")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(SpringActionButtonStyle())
                        .disabled(!hapticEnabled)
                        
                        Button(action: {
                            if hapticEnabled {
                                HapticManager.shared.playHaptic(style: .decrement)
                            }
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(hapticEnabled ? Color.red.opacity(0.15) : Color.gray.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(hapticEnabled ? .red : .gray)
                                }
                                
                                Text("Decrement")
                                    .font(.caption)
                            }
                        }
                        .buttonStyle(SpringActionButtonStyle())
                        .disabled(!hapticEnabled)
                    }
                }
                .padding(.vertical, 8)
                
                // Save Button
                ModernActionButton(text: "Save", action: {
                    saveHaptics()
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isPresented = false
                    }
                })
                .padding(.horizontal, 20)
                .padding(.top, 20)
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
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
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
                
                Image(systemName: "waveform")
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
