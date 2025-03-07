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
            
            VStack(spacing: 80) {
                CountifyAppIconUI(size: 210)
                
                Text("Countify")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    LaunchScreen()
}
