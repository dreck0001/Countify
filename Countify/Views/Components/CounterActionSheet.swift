//
//  CounterActionSheet.swift
//  Countify
//
//  Created by Throw Catchers on 2/19/25.
//

import SwiftUI

// 1. First, let's create the bottom sheet UI
struct CounterActionSheet: View {
    @Binding var isPresented: Bool
    let session: CountSession
    let sessionManager: CountSessionManager
    @Binding var showingRenameAlert: Bool
    
    // To handle drag gesture for dismissing
    @GestureState private var dragOffset = CGSize.zero
    @State private var offset: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background with easy tap-to-dismiss
            Color.black.opacity(0.4)
                .ignoresSafeArea(edges: .all) // Ensure it covers everything
                .onTapGesture {
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
            
            VStack(spacing: 0) {
                // Drag indicator
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.secondary.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                
                // Quick actions row with smaller size
                HStack(spacing: 40) {
                    // Reset action
                    VStack {
                        Button(action: {
                            resetCounter()
                            dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 20))
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Text("Reset")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    
                    // Save action
                    VStack {
                        Button(action: {
                            // Implement save to favorites functionality
                            hapticFeedback()
                            dismiss()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "star")
                                    .font(.system(size: 20))
                                    .foregroundColor(.primary)
                            }
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Text("Favorite")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.bottom, 16)
                
                // Menu items in a more compact layout
                VStack(spacing: 0) {
                    CompactActionMenuItem(icon: "pencil", text: "Rename", action: {
                        // First dismiss sheet, then show rename alert
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                        // Longer delay to ensure complete dismissal
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            showingRenameAlert = true
                        }
                    })
                    
                    CompactActionMenuItem(icon: "doc.on.doc", text: "Duplicate", action: {
                        duplicateCounter()
                        dismiss()
                    })
                    
                    // Delete action (destructive) - integrated into main menu
                    CompactActionMenuItem(icon: "trash", text: "Delete", action: {
                        deleteCounter()
                        dismiss()
                    }, isDestructive: true)
                }
                .padding(.bottom, 24) // Extra padding at bottom for safety
            }
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.systemGray6)) // Light gray slick background
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
                        if value.translation.height > 50 { // Reduced threshold for dismissal
                            // Dismiss if dragged down even a little
                            dismiss()
                        } else {
                            // Spring back
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
            .frame(maxWidth: .infinity)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .transition(.move(edge: .bottom))
            // Add padding to lift it slightly from the very bottom edge
            .padding(.bottom, 10)
        }
        .ignoresSafeArea(edges: .all) // Make sure it covers everything including tab bars
    }
    
    // Helper functions
    private func dismiss() {
        withAnimation(.spring()) {
            isPresented = false
        }
    }
    
    private func resetCounter() {
        var updatedSession = session
        updatedSession.count = 0
        sessionManager.saveSession(updatedSession)
        
        if session.hapticEnabled {
            HapticManager.shared.playHaptic(style: .decrement)
        }
    }
    
    private func duplicateCounter() {
        let newSession = CountSession(
            name: "\(session.name) Copy",
            count: session.count,
            hapticEnabled: session.hapticEnabled,
            allowNegatives: session.allowNegatives,
            stepSize: session.stepSize,
            upperLimit: session.upperLimit,
            lowerLimit: session.lowerLimit
        )
        sessionManager.saveSession(newSession)
        
        if session.hapticEnabled {
            HapticManager.shared.playHaptic(style: .increment)
        }
    }
    
    private func deleteCounter() {
        if let index = sessionManager.sessions.firstIndex(where: { $0.id == session.id }) {
            sessionManager.deleteSession(at: IndexSet(integer: index))
            if session.hapticEnabled {
                HapticManager.shared.playHaptic(style: .decrement)
            }
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// 2. Action menu item component
struct ActionMenuItem: View {
    let icon: String
    let text: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.primary.opacity(0.8))
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 12)
                
                Text(text)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
    }
}
// 3. Scale button style for the quick actions
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}
// 4. Updated LargeCountCard with ellipsis button
struct UpdatedLargeCountCard: View {
    let session: CountSession
    let onEllipsisPress: () -> Void
    
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
            
            // Ellipsis button instead of chevron
            Button(action: onEllipsisPress) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(10)
                    .contentShape(Rectangle())
            }
            .padding(.trailing, 8)
        }
        .frame(height: 120) // Larger card height
        .frame(maxWidth: .infinity)
        .background(cardBackground)
    }
}
// 2. Fixed UpdatedLongPressableCard to prevent navigation on long press
struct UpdatedLongPressableCard<Destination: View>: View {
    let session: CountSession
    let destination: Destination
    let onLongPress: () -> Void
    let onEllipsisPress: () -> Void
    
    @State private var isPressed = false
    @GestureState private var longPress = false
    @State private var shouldNavigate = true
    
    var body: some View {
        ZStack {
            if shouldNavigate {
                NavigationLink(destination: destination) {
                    UpdatedLargeCountCard(session: session, onEllipsisPress: onEllipsisPress)
                }
                .buttonStyle(CardPressStyle())
            } else {
                UpdatedLargeCountCard(session: session, onEllipsisPress: onEllipsisPress)
                    .onTapGesture {
                        // Re-enable navigation after a tap on the card when not in long press
                        if !longPress {
                            shouldNavigate = true
                        }
                    }
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .updating($longPress) { currentState, gestureState, _ in
                    gestureState = currentState
                    if currentState {
                        shouldNavigate = false
                    }
                }
                .onEnded { _ in
                    hapticFeedback()
                    shouldNavigate = false
                    onLongPress()
                    
                    // Re-enable navigation after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        shouldNavigate = true
                    }
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

struct CompactActionMenuItem: View {
    let icon: String
    let text: String
    let action: () -> Void
    var isDestructive: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isDestructive ? .red : .primary.opacity(0.8))
                    .frame(width: 20, height: 20)
                    .padding(.trailing, 10)
                
                Text(text)
                    .foregroundColor(isDestructive ? .red : .primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
    }
}

//#Preview {
//    CounterActionSheet()
//}
