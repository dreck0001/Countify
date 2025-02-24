//
//  CountSessionCard.swift
//  Countify
//
//  Created by Throw Catchers on 2/22/25.
//

import SwiftUI

struct CountSessionCard<Destination: View>: View {
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
                    LargeCountSessionCard(session: session, onEllipsisPress: onEllipsisPress)
                }
                .buttonStyle(CardPressStyle())
            } else {
                LargeCountSessionCard(session: session, onEllipsisPress: onEllipsisPress)
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


#Preview {
    NavigationView {
        CountSessionCard(
            session: CountSession(
                name: "Daily Steps",
                count: 8423,
                hapticEnabled: true,
                allowNegatives: false,
                stepSize: 5,
                upperLimit: 10000,
                lowerLimit: 0
            ),
            destination: Text("Counter Details View"),
            onLongPress: { print("Long press triggered") },
            onEllipsisPress: { print("Ellipsis pressed") }
        )
        .padding()
    }
}
