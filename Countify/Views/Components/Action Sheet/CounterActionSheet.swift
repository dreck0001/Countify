//
//  CounterActionSheet.swift
//  Countify
//
//  Created by Throw Catchers on 2/19/25.
//

import SwiftUI

struct CounterActionSheet: View {
    @Binding var isPresented: Bool
    let session: CountSession
    let sessionManager: CountSessionManager
    @Binding var showingRenameAlert: Bool
    
    // Gesture states for drag and spring animations
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    
    // Animation configuration
    private let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)
    private let appearAnimation = Animation.spring(response: 0.55, dampingFraction: 0.7)
    
    // Sheet dimensions
    private let cornerRadius: CGFloat = 32
    
    var body: some View {
        ZStack {
            // Background overlay with blur effect for depth
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                // Animated opacity with the sheet for smoother appearance
                .opacity(isPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: isPresented)
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Action sheet content
            VStack(spacing: 0) {
                // Drag indicator with subtle animation on drag - Instagram style
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                    .scaleEffect(isDragging ? 1.2 : 1)
                    .animation(.spring(response: 0.2), value: isDragging)
                
                // Quick actions row with enhanced visual style
                HStack(spacing: 40) {
                    // Reset action
                    VStack {
                        ActionButton(
                            icon: "arrow.counterclockwise",
                            background: Color.gray.opacity(0.12),
                            foreground: .primary
                        ) {
                            resetCounter()
                            dismiss()
                        }
                        
                        Text("Reset")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.top, 6)
                    }
                    
                    // Favorite action
                    VStack {
                        ActionButton(
                            icon: session.favorite ? "star.fill" : "star",
                            background: session.favorite ? Color.yellow.opacity(0.15) : Color.gray.opacity(0.12),
                            foreground: session.favorite ? .yellow : .primary
                        ) {
                            toggleFavorite()
                        }
                        
                        Text("Favorite")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.top, 6)
                    }
                }
                .padding(.bottom, 24)
                
                // Action menu items with enhanced styling
                VStack(spacing: 0) {
                    ModernActionMenuItem(
                        icon: "pencil",
                        text: "Rename",
                        action: {
                            withAnimation(springAnimation) {
                                isPresented = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showingRenameAlert = true
                            }
                        }
                    )
                    
                    ModernActionMenuItem(
                        icon: "doc.on.doc",
                        text: "Duplicate",
                        action: {
                            duplicateCounter()
                            dismiss()
                        }
                    )
                    
                    ModernActionMenuItem(
                        icon: "trash",
                        text: "Delete",
                        isDestructive: true,
                        action: {
                            deleteCounter()
                            dismiss()
                        }
                    )
                }
                .padding(.bottom, 28)
            }
            .padding(.horizontal, 20)
            .background(
                ZStack {
                    // Instagram-style background - completely solid
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(.systemGray6)) // Remove opacity modifier
                        
                    // Top edge highlight line
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                }
            )
            .compositingGroup() // Ensures the shadow applies to the entire group
            .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 0)
            .offset(y: isPresented ? offset.height : UIScreen.main.bounds.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow dragging downward
                        if value.translation.height > 0 {
                            offset = value.translation
                            isDragging = true
                        }
                    }
                    .onEnded { value in
                        // Dismiss if dragged far enough
                        if value.translation.height > 120 || value.predictedEndTranslation.height > 200 {
                            dismissWithAnimation()
                        } else {
                            // Spring back to original position
                            withAnimation(springAnimation) {
                                offset = .zero
                                isDragging = false
                            }
                        }
                    }
            )
            .animation(appearAnimation, value: isPresented)
            .frame(maxHeight: .infinity, alignment: .bottom)
            .padding(.bottom, 10)
        }
        .ignoresSafeArea()
    }
    
    private func toggleFavorite() {
        var updatedSession = session
        updatedSession.favorite = !session.favorite
        sessionManager.saveSession(updatedSession)
        
        if session.hapticEnabled {
            // Use a star-like haptic pattern
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred(intensity: 0.8)
        }
        
        dismiss()
    }
    
    // Helper methods with improved haptic feedback
    private func dismiss() {
        dismissWithAnimation()
    }
    
    private func dismissWithAnimation() {
        withAnimation(springAnimation) {
            isPresented = false
            offset = .zero
            isDragging = false
        }
        
        // No haptic feedback when simply dismissing
    }
    
    private func resetCounter() {
        var updatedSession = session
        updatedSession.count = 0
        sessionManager.saveSession(updatedSession)
        
        if session.hapticEnabled {
            // Enhanced haptic pattern for reset
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)
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
                // More pronounced feedback for delete
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        }
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred(intensity: 0.7)
    }
}

struct ActionButton: View {
    let icon: String
    let background: Color
    let foreground: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(background)
                    .frame(width: 58, height: 58)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(foreground)
            }
        }
        .buttonStyle(SpringyButtonStyle())
    }
}

struct ModernActionMenuItem: View {
    let icon: String
    let text: String
    let isDestructive: Bool
    let action: () -> Void
    
    init(icon: String, text: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.text = text
        self.isDestructive = isDestructive
        self.action = action
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(isDestructive ? Color.red.opacity(0.1) : Color.primary.opacity(0.05))
                        .frame(width: 34, height: 34)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isDestructive ? .red : .primary)
                }
                
                Text(text)
                    .font(.system(size: 17, weight: isDestructive ? .semibold : .regular))
                    .foregroundColor(isDestructive ? .red : .primary)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isPressed ? Color.primary.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct SpringyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView {
        UIVisualEffectView()
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) {
        uiView.effect = effect
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

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

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
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
