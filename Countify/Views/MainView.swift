//
//  MainView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = CountSessionManager()
    
    var body: some View {
        TabView {
            CountSessionListView(sessionManager: sessionManager)
                .tabItem {
                    Label("Countify", systemImage: "minus.forwardslash.plus")
                }
            
            SettingsView(sessionManager: sessionManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            // Make tab bar background transparent
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithTransparentBackground()
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            UITabBar.appearance().standardAppearance = tabBarAppearance
        }
    }
}

#Preview {
    ContentView()
}
