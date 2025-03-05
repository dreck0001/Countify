//
//  EmptyStateView.swift
//  Countify
//
//  Created by Throw Catchers on 2/17/25.
//

import SwiftUI

struct EmptyStateView: View {
    let action: () -> Void
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ScrollView {
                VStack(spacing: 24) {
                    CountifyAppIconUI(size: 180)
                        .padding(.top, 20)
                    
                    VStack(spacing: 4) {
                        Text("Welcome to Countify")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("Your Personal Counter Companion")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, 16)
                    
                    // Top two feature cards
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        FeatureCard(
                            icon: "rectangle.stack",
                            title: "Multiple Sessions",
                            description: "Create and manage multiple counting sessions"
                        )
                        
                        FeatureCard(
                            icon: "gear",
                            title: "Customizable",
                            description: "Configure each counter with your preferred settings"
                        )
                    }
                    .padding(.horizontal)
                    
                    VStack(spacing: 24) {
                        // Customizable Experiences - Multiple cards
                        WideFeatureCard(
                            icon: "arrow.up.arrow.down",
                            title: "Custom Step Sizes",
                            description: "Increment or decrement by any value - perfect for counting by 2s, 5s, or any number you choose"
                        )
                        
                        WideFeatureCard(
                            icon: "ruler",
                            title: "Set Counting Limits",
                            description: "Define upper and lower bounds for your counters to prevent going beyond desired ranges"
                        )
                        
                        WideFeatureCard(
                            icon: "hand.tap",
                            title: "Haptic Feedback",
                            description: "Feel distinct vibration patterns for different actions - increment, decrement, and reset operations"
                        )
                        
                        WideFeatureCard(
                            icon: "icloud",
                            title: "Automatic Saving",
                            description: "Never lose your counts - all sessions are automatically saved as you go"
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 80) // Space for the button
                }
            }
            
            // Fixed Button at bottom
            VStack {
                Button(action: action) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                        Text("Create Your First Counter")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 16) )
                    .contentShape(RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.white)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
            .background(
                Rectangle()
                    .fill(.background)
                    .ignoresSafeArea()
                    .frame(height: 100)
            )
        }
    }
}

// Regular Feature Card
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true) // Ensures text doesn't get cut off
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemFill))
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
        )
    }
}

// Wide Feature Card
struct WideFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon with gradient background
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.blue)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true) // Ensures text doesn't get cut off
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemFill))
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 5)
        )
    }
}

#Preview {
    Group {
        EmptyStateView(action: {})
    }
}
