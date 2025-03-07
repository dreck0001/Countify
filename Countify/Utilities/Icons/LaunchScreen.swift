//
//  LaunchScreen.swift
//  Countify
//
//  Created by Throw Catchers on 3/6/25.
//

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: geometry.size.height * 0.1) {
                    // Icon size relative to screen width
                    let iconSize = min(geometry.size.width * 0.5, 280)
                    
                    Spacer()
                    
                    CountifyAppIconUI(size: iconSize)
                    
                    Text("Countify")
                        .font(.system(size: min(48, geometry.size.width * 0.12), weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width)
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
