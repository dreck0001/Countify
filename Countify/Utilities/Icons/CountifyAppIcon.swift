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
        HStack(spacing: 0) {
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
                                lineWidth: max(1, size * 0.0125)
                            )
                    )
                
                Text("−")
                    .font(.system(size: size * 0.625, weight: .medium))
                    .foregroundColor(decrementColor)
            }
            .offset(x: size * 0.1, y: 0)
            
            // Increment button visual (non-functional)
            ZStack {
                Circle()
                    .fill(incrementColor.opacity(0.15))
                    .frame(width: size, height: size)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                incrementColor.opacity(0.3),
                                lineWidth: max(1, size * 0.0125)
                            )
                    )
                
                Text("+")
                    .font(.system(size: size * 0.625, weight: .medium))
                    .foregroundColor(incrementColor)
            }
            .offset(x: -size * 0.1, y: 0)
            
            Spacer()
        }
    }
}


#Preview {
    VStack {
        CountifyAppIconUI()
        CountifyAppIconUI(size: 80)
        CountifyAppIconUI(size: 160)
        CountifyAppIconUI(size: 240)
        CountifyAppIconUI(size: 300)
    }
    .padding()
}
