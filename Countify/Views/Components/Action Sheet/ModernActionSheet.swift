//
//  ModernActionSheet.swift
//  Countify
//
//  Created by Throw Catchers on 2/25/25.
//

import SwiftUI

// base action sheet for all feature sheets
struct ModernActionSheet<Content: View>: View {
    @Binding var isPresented: Bool
    let title: String
    let content: Content
    
    // Animation states
    @State private var offset = CGSize.zero
    @State private var isDragging = false
    
    // For keyboard avoidance
    @State private var keyboardHeight: CGFloat = 0
    
    // Animation configurations for smooth transitions
    private let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)
    private let appearAnimation = Animation.spring(response: 0.55, dampingFraction: 0.7)
    
    // Sheet dimensions and styling - full width with rounded top corners only
    private let topCornerRadius: CGFloat = 16  // Increased corner radius
    private let sheetWidth: CGFloat = UIScreen.main.bounds.width
    
    init(isPresented: Binding<Bool>, title: String, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // Semi-transparent backdrop
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .opacity(isPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: isPresented)
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Main content sheet - full width with rounded top corners, Instagram style
            VStack(spacing: 0) {
                // Drag indicator with animation on drag - Instagram style
                RoundedRectangle(cornerRadius: 2.5)
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                    .scaleEffect(isDragging ? 1.2 : 1)
                    .animation(.spring(response: 0.2), value: isDragging)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.bottom, 16)
                
                content
                    .padding(.bottom, 30) // Add extra padding at the bottom to extend beyond the visible area
            }
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    // Instagram-style background - completely solid
                    RoundedCorners(tl: topCornerRadius, tr: topCornerRadius, bl: 0, br: 0)
                        .fill(Color(.systemGray6)) // Remove opacity modifier
                    
                    // Simple top edge stroke
                    RoundedCorners(tl: topCornerRadius, tr: topCornerRadius, bl: 0, br: 0)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                }
            )
            .frame(width: sheetWidth) // Full width sheet
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: -2)
            .offset(y: isPresented ? offsetWithKeyboard : UIScreen.main.bounds.height)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Only allow dragging downward when keyboard is not showing
                        if keyboardHeight == 0 && value.translation.height > 0 {
                            offset = value.translation
                            isDragging = true
                        }
                    }
                    .onEnded { value in
                        // Dismiss if dragged far enough when keyboard is not showing
                        if keyboardHeight == 0 && (value.translation.height > 120 || value.predictedEndTranslation.height > 200) {
                            dismissWithAnimation()
                        } else {
                            // Spring back to original position with animation
                            withAnimation(springAnimation) {
                                offset = .zero
                                isDragging = false
                            }
                        }
                    }
            )
            .animation(appearAnimation, value: isPresented)
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .ignoresSafeArea()
        .onAppear {
            addKeyboardObservers()
        }
        .onDisappear {
            removeKeyboardObservers()
        }
    }
    
    // Calculate offset including keyboard adjustments
    private var offsetWithKeyboard: CGFloat {
        if keyboardHeight > 0 {
            // Push content above keyboard with some padding
            return -keyboardHeight + 20
        } else {
            // Normal position with any manual drag offset
            return offset.height
        }
    }
    
    private func dismissWithAnimation() {
        // Smooth dismissal animation without haptic feedback
        withAnimation(springAnimation) {
            isPresented = false
            offset = .zero
            isDragging = false
        }
        // No haptic feedback when dismissing
    }
    
    // Keyboard observers
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            
            withAnimation(.easeInOut(duration: animationDuration)) {
                self.keyboardHeight = keyboardFrame.height
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
            
            withAnimation(.easeInOut(duration: animationDuration)) {
                self.keyboardHeight = 0
            }
        }
    }
    
    private func removeKeyboardObservers() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}


// Custom shape for rounded corners only at the top
struct RoundedCorners: Shape {
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let w = rect.size.width
        let h = rect.size.height
        
        // Make sure we don't exceed the size of the rectangle
        let tr = min(min(self.tr, h/2), w/2)
        let tl = min(min(self.tl, h/2), w/2)
        let bl = min(min(self.bl, h/2), w/2)
        let br = min(min(self.br, h/2), w/2)
        
        path.move(to: CGPoint(x: w / 2.0, y: 0))
        path.addLine(to: CGPoint(x: w - tr, y: 0))
        path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: w, y: h - br))
        path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: bl, y: h))
        path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: 0, y: tl))
        path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
        path.closeSubpath()
        
        return path
    }
}
//springy button for action sheets
struct ModernActionButton: View {
    let text: String
    let action: () -> Void
    var foregroundColor: Color = .white
    var backgroundColor: Color = .blue
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        // Main background
                        RoundedRectangle(cornerRadius: 16)
                            .fill(backgroundColor)
                        
                        // Subtle gradient overlay for depth
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.1),
                                        Color.clear,
                                        Color.black.opacity(0.05)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                )
                .shadow(color: backgroundColor.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(SpringActionButtonStyle())
    }
}

// Button style with spring animation
struct SpringActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

//number stepper
struct ModernStepper: View {
    @Binding var value: Int
    var range: ClosedRange<Int>
    var step: Int = 1
    var size: CGFloat = 44
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: {
                if value > range.lowerBound {
                    let newValue = value - step
                    value = max(range.lowerBound, newValue)
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(value > range.lowerBound ? .primary : .gray)
                    .frame(width: size, height: size)
                    .background(
                        Circle()
                            .fill(Color.primary.opacity(0.05))
                    )
            }
            .disabled(value <= range.lowerBound)
            .buttonStyle(SpringActionButtonStyle())
            
            Text("\(value)")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .frame(minWidth: 40)
            
            Button(action: {
                if value < range.upperBound {
                    let newValue = value + step
                    value = min(range.upperBound, newValue)
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(value < range.upperBound ? .primary : .gray)
                    .frame(width: size, height: size)
                    .background(
                        Circle()
                            .fill(Color.primary.opacity(0.05))
                    )
            }
            .disabled(value >= range.upperBound)
            .buttonStyle(SpringActionButtonStyle())
        }
    }
}

//toggle with enhanced appearance
struct ModernToggle: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.system(size: 17))
        }
        .toggleStyle(SwitchToggleStyle(tint: .blue))
        .padding(.vertical, 4)
    }
}

//circle button for feature selection
struct ModernCircleButton: View {
    let icon: String
    let text: String
    let isActive: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isActive ? color.opacity(0.15) : Color.primary.opacity(0.05))
                        .frame(width: 60, height: 60)
                        .shadow(color: isActive ? color.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isActive ? color : .gray)
                }
                
                Text(text)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(isActive ? .primary : .secondary)
            }
        }
        .buttonStyle(SpringActionButtonStyle())
    }
}
