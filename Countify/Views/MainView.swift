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
                    Label("Countify", systemImage: "number.circle.fill")
                }
            
            SettingsView(sessionManager: sessionManager)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
