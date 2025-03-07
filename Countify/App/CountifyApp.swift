//
//  CountifyApp.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

@main
struct CountifyApp: App {
    @State private var isShowingLaunchScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                
                if isShowingLaunchScreen {
                    LaunchScreen()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                withAnimation(.easeOut(duration: 0.4)) {
                                    isShowingLaunchScreen = false
                                }
                            }
                        }
                }
            }
        }
    }
}
