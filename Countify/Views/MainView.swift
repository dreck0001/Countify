//
//  MainView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionManager = CountSessionManager()
    @State private var showingActionSheet = false
    @State private var selectedSession: CountSession? = nil
    @State private var showingRenameAlert = false
    
    // Create a shared state between ContentView and CountSessionListView
    @State private var isShowingActionSheet = false
    @State private var actionSheetSession: CountSession? = nil
    
    var body: some View {
        ZStack {
            TabView {
                CountSessionListViewWrapper(
                    sessionManager: sessionManager,
                    isShowingActionSheet: $isShowingActionSheet,
                    actionSheetSession: $actionSheetSession,
                    showingRenameAlert: $showingRenameAlert
                )
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
                tabBarAppearance.configureWithOpaqueBackground()
                UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
                UITabBar.appearance().standardAppearance = tabBarAppearance
            }
            
            // Action sheet overlay on top of everything
            if isShowingActionSheet, let session = actionSheetSession {
                CounterActionSheet(
                    isPresented: $isShowingActionSheet,
                    session: session,
                    sessionManager: sessionManager,
                    showingRenameAlert: $showingRenameAlert
                )
            }
        }
    }
}


#Preview {
    ContentView()
}
