//
//  CountSessionListView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct CountSessionListView: View {
    @ObservedObject var sessionManager: CountSessionManager
    @Binding var showingActionSheet: Bool
    @Binding var actionSheetSession: CountSession?
    @Binding var showingRenameAlert: Bool
    
    @State private var searchText = ""
    @State private var showingNewSession = false
    @State private var newSessionName = ""
    
    // Filter sessions based on search text
    var filteredSessions: [CountSession] {
        if searchText.isEmpty {
            return sessionManager.sessions.sorted(by: { $0.date > $1.date })
        } else {
            return sessionManager.sessions
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
                .sorted(by: { $0.date > $1.date })
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Empty state view when no sessions exist
                if sessionManager.sessions.isEmpty {
                    EmptyStateView(action: { showingNewSession = true })
                } else {
                    VStack(spacing: 0) {
                        // Search bar
                        SearchBar(text: $searchText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        
                        if filteredSessions.isEmpty {
                            // No search results view
                            VStack(spacing: 16) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary.opacity(0.6))
                                    .padding(.top, 80)
                                
                                Text("No counters found")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                                
                                Text("Try a different search term")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary.opacity(0.8))
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.clear)
                        } else {
                            // List of count sessions
                            ScrollView {
                                VStack(spacing: 20) {
                                    ForEach(filteredSessions) { session in
                                        CountSessionCard(
                                            session: session,
                                            destination: CountingSessionView(
                                                session: session,
                                                sessionManager: sessionManager
                                            ),
                                            onLongPress: {
                                                actionSheetSession = session
                                                newSessionName = session.name
                                                showingActionSheet = true
                                            },
                                            onEllipsisPress: {
                                                actionSheetSession = session
                                                newSessionName = session.name
                                                showingActionSheet = true
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                            .background(Color.clear)
                        }
                    }
                }
                
                // Floating Action Button
                if !sessionManager.sessions.isEmpty {
                    VStack {
                        Spacer()
                            Button(action: { showingNewSession = true }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 80, height: 80)
                                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        
                                    Image(systemName: "plus")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            }
                            .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Countify")
            .sheet(isPresented: $showingNewSession) {
                NewSessionView(sessionManager: sessionManager, isPresented: $showingNewSession)
            }
            .onAppear {
                if let session = actionSheetSession {
                    newSessionName = session.name
                }
            }
            .onChange(of: showingRenameAlert) { isShowing in
                if isShowing, let session = actionSheetSession {
                    newSessionName = session.name
                }
            }
            .alert("Rename Counter", isPresented: $showingRenameAlert) {
                TextField("Counter Name", text: $newSessionName)
                
                Button("Save") {
                    if let session = actionSheetSession, !newSessionName.isEmpty {
                        var updatedSession = session
                        updatedSession.name = newSessionName
                        sessionManager.saveSession(updatedSession)
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    if let session = actionSheetSession {
                        newSessionName = session.name
                    }
                }
            } message: {
                Text("Enter a new name for this counter")
            }
        }
    }
}


struct LongPressableCard<Destination: View>: View {
    let session: CountSession
    let destination: Destination
    let onLongPress: () -> Void
    
    @State private var isPressed = false
    @GestureState private var longPress = false
    
    var body: some View {
        NavigationLink(destination: destination) {
            LargeCountCard(session: session)
        }
        .buttonStyle(CardPressStyle())
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($longPress) { currentState, gestureState, _ in
                    gestureState = currentState
                }
                .onEnded { _ in
                    hapticFeedback()
                    onLongPress()
                }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(longPress ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(longPress ? 0.98 : 1)
        .animation(.easeInOut(duration: 0.2), value: longPress)
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
// Larger, more visually appealing count card
struct LargeCountCard: View {
    let session: CountSession
    
    // Glass effect background for cards
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.primary.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
    
    private func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: session.date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) \(hour == 1 ? "hour" : "hours") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) \(minute == 1 ? "min" : "mins") ago"
        } else {
            return "Just now"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Count number with glassy background
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Text("\(session.count)")
                    .font(.system(size: 42, weight: .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .foregroundColor(.white)
            }
            .padding(.leading, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(session.name)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                
                // Feature indicators as simple icons in a row
                HStack(spacing: 10) {
                    if session.stepSize > 1 {
                        FeatureTag(icon: "arrow.up.arrow.down", text: "")
                    }
                    
                    if session.hapticEnabled {
                        FeatureTag(icon: "waveform", text: "")
                    }
                    
                    if session.allowNegatives {
                        FeatureTag(icon: "plusminus", text: "")
                    }
                    
                    if session.upperLimit != nil || session.lowerLimit != nil {
                        FeatureTag(icon: "ruler", text: "")
                    }
                }
                
                Text(timeAgo())
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .padding(.vertical, 16)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.secondary.opacity(0.8))
                .padding(.trailing, 16)
        }
        .frame(height: 120) // Larger card height
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }
}


// Flow layout for wrapping feature tags
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        
        return layout(for: width, subviews: subviews)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let width = bounds.width
        
        var point = CGPoint(x: bounds.minX, y: bounds.minY)
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if point.x + size.width > width {
                point.x = bounds.minX
                point.y += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(at: point, proposal: .unspecified)
            
            lineHeight = max(lineHeight, size.height)
            point.x += size.width + spacing
        }
    }
    
    func layout(for width: CGFloat, subviews: Subviews) -> CGSize {
        var point = CGPoint.zero
        var lineHeight: CGFloat = 0
        var heights: [CGFloat] = []
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            
            if point.x + size.width > width {
                heights.append(lineHeight)
                point.x = 0
                point.y += lineHeight + spacing
                lineHeight = 0
            }
            
            lineHeight = max(lineHeight, size.height)
            point.x += size.width + spacing
        }
        
        heights.append(lineHeight)
        
        let height = heights.reduce(0, +) + spacing * CGFloat(max(0, heights.count - 1))
        return CGSize(width: width, height: height)
    }
}


// Collapsible features view
struct CollapsibleFeaturesView: View {
    let session: CountSession
    
    var body: some View {
        VStack(spacing: 16) {
            // First row: Primary features
            HStack(spacing: 12) {
                CounterFeatureCard(
                    icon: "hand.tap.fill",
                    title: "Haptic",
                    value: session.hapticEnabled ? "On" : "Off",
                    color: .blue
                )
                
                CounterFeatureCard(
                    icon: "plusminus.circle.fill",
                    title: "Negatives",
                    value: session.allowNegatives ? "Allowed" : "Disabled",
                    color: .purple
                )
            }
            
            // Second row: Numeric settings
            HStack(spacing: 12) {
                CounterFeatureCard(
                    icon: "arrow.up.forward.square.fill",
                    title: "Step Size",
                    value: "\(session.stepSize)",
                    color: .green
                )
                
                let limitsText = getLimitsDescription()
                CounterFeatureCard(
                    icon: "ruler.fill",
                    title: "Limits",
                    value: limitsText,
                    color: limitsText == "None" ? .gray : .orange
                )
            }
        }
    }
    
    private func getLimitsDescription() -> String {
        if let lower = session.lowerLimit, let upper = session.upperLimit {
            return "\(lower) - \(upper)"
        } else if let lower = session.lowerLimit {
            return "Min: \(lower)"
        } else if let upper = session.upperLimit {
            return "Max: \(upper)"
        }
        return "None"
    }
}

// Feature card for collapsible section
struct CounterFeatureCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(height: 110)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
}

// Enhanced counter display with transparency and style
struct EnhancedCounterDisplayView: View {
    let count: Int
    let isIncrementing: Bool
    
    var body: some View {
        ZStack {
            // Glassmorphism effect for background
            RoundedRectangle(cornerRadius: 35)
                .fill(Color.primary.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 35)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                )
                .frame(height: 320)
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: 5)
            
            Text("\(count)")
                .font(.system(size: 160, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.3)
                .lineLimit(1)
                .padding(.horizontal, 30)
                .foregroundColor(.primary.opacity(0.9))
                .contentTransition(.numericText(countsDown: !isIncrementing))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: count)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

// Enhanced counter controls with transparency
struct EnhancedCounterControlsView: View {
    @Binding var session: CountSession
    @Binding var isIncrementing: Bool
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                
                EnhancedDecrementButton(session: $session, isIncrementing: $isIncrementing, onSave: onSave)
                
                Spacer()
                Spacer()
                
                EnhancedIncrementButton(session: $session, isIncrementing: $isIncrementing, onSave: onSave)
                
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

// Enhanced buttons with glass effect
struct EnhancedDecrementButton: View {
    @Binding var session: CountSession
    @Binding var isIncrementing: Bool
    let onSave: () -> Void
    
    private var canDecrement: Bool {
        if let lowerLimit = session.lowerLimit {
            return session.count > lowerLimit
        }
        return session.allowNegatives || session.count > 0
    }
    
    var body: some View {
        Button(action: {
            if canDecrement {
                isIncrementing = false
                if session.hapticEnabled {
                    HapticManager.shared.playHaptic(style: .decrement)
                }
                session.count -= session.stepSize
                onSave()
            }
        }) {
            ZStack {
                Circle()
                    .fill(canDecrement ?
                          Color.red.opacity(0.15) :
                          Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                canDecrement ?
                                    Color.red.opacity(0.3) :
                                    Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                
                Text("−")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(canDecrement ? .red : .gray)
            }
        }
        .disabled(!canDecrement)
    }
}

struct EnhancedIncrementButton: View {
    @Binding var session: CountSession
    @Binding var isIncrementing: Bool
    let onSave: () -> Void
    
    private var canIncrement: Bool {
        if let upperLimit = session.upperLimit {
            return session.count < upperLimit
        }
        return true
    }
    
    var body: some View {
        Button(action: {
            if canIncrement {
                isIncrementing = true
                if session.hapticEnabled {
                    HapticManager.shared.playHaptic(style: .increment)
                }
                session.count += session.stepSize
                onSave()
            }
        }) {
            ZStack {
                Circle()
                    .fill(canIncrement ?
                          Color.green.opacity(0.15) :
                          Color.gray.opacity(0.1))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                canIncrement ?
                                    Color.green.opacity(0.3) :
                                    Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                
                Text("+")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(canIncrement ? .green : .gray)
            }
        }
        .disabled(!canIncrement)
    }
}

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(text.isEmpty ? .secondary : .primary)
                .padding(.leading, 8)
            
            TextField("Search counters", text: $text)
                .padding(10)
                .focused($isFocused)
                .submitLabel(.search)
                .autocorrectionDisabled(true)
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    isFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .padding(.trailing, 8)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.primary.opacity(0.1), lineWidth: 1)
                )
        )
        .frame(height: 44)
    }
}

struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    CountSessionListView(
        sessionManager: CountSessionManager(),
        showingActionSheet: .constant(false),
        actionSheetSession: .constant(nil),
        showingRenameAlert: .constant(false)
    )
}
