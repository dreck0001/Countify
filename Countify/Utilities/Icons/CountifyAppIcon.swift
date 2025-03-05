//
//  CountifyAppIcon.swift
//  Countify
//
//  Created by Throw Catchers on 2/27/25.
//

import SwiftUI

struct CountifyAppIconUI: View {
    var size: CGFloat = 80 // Configurable size parameter
    var incrementColor: Color = .green
    var decrementColor: Color = .red
    
    var body: some View {
        HStack {
            Spacer()
            // Decrement button visual (non-functional)
            ZStack {
                Circle()
                    .fill(decrementColor.opacity(0.15))
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                decrementColor.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                
                Text("−")
                    .font(.system(size: size * 0.625, weight: .medium))
                    .foregroundColor(decrementColor)
            }
            .offset(x: 20, y: 0)
            
            // Increment button visual (non-functional)
            ZStack {
                Circle()
                    .fill(incrementColor.opacity(0.15))
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                incrementColor.opacity(0.3),
                                lineWidth: 1
                            )
                    )
                
                Text("+")
                    .font(.system(size: size * 0.625, weight: .medium))
                    .foregroundColor(incrementColor)
            }
            .offset(x: -20, y: 0)
            Spacer()
        }
    }
}
#Preview {
    VStack {
        // Standard size
        CountifyAppIconUI()
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        
        // Small icon size
        CountifyAppIconUI(size: 40)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
        
        // Large icon size with custom colors
        CountifyAppIconUI(
            size: 100,
            incrementColor: .blue,
            decrementColor: .orange
        )
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
    .padding()
}
