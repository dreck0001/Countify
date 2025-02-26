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
    
    // Animation configurations for smooth transitions
    private let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)
    private let appearAnimation = Animation.spring(response: 0.55, dampingFraction: 0.7)
    
    // Sheet dimensions and styling
    private let cornerRadius: CGFloat = 32
    
    init(isPresented: Binding<Bool>, title: String, @ViewBuilder content: () -> Content) {
        self._isPresented = isPresented
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .opacity(isPresented ? 1 : 0)
                .animation(.easeInOut(duration: 0.25), value: isPresented)
                .onTapGesture {
                    dismissWithAnimation()
                }
            
            // Main content sheet
            VStack(spacing: 0) {
                // Drag indicator with animation on drag
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 40, height: 6)
                    .padding(.top, 14)
                    .padding(.bottom, 8)
                    .scaleEffect(isDragging ? 1.2 : 1)
                    .animation(.spring(response: 0.2), value: isDragging)
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .padding(.bottom, 20)
                
                content
                    .padding(.bottom, 28)
            }
            .padding(.horizontal, 20)
            .background(
                // Modern glass effect background
                ZStack {
                    // Blurred background layer
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(.systemBackground).opacity(0.8))
                        .background(
                            VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                                .cornerRadius(cornerRadius)
                        )
                    
                    // Subtle border for definition
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                }
            )
            .compositingGroup() // Ensures the shadow applies to the entire group
            .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
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
            .padding(.bottom, 10)
        }
        .ignoresSafeArea()
    }
    
    private func dismissWithAnimation() {
        // Smooth dismissal animation
        withAnimation(springAnimation) {
            isPresented = false
            offset = .zero
            isDragging = false
        }
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
