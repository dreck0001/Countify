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
    @State private var actionSheetSession: CountSession? = nil
    @State private var showingRenameAlert = false
    @State private var showingNewSession = false
    
    var body: some View {
        ZStack {
            CountSessionListView(
                sessionManager: sessionManager,
                showingActionSheet: $showingActionSheet,
                actionSheetSession: $actionSheetSession,
                showingRenameAlert: $showingRenameAlert,
                showingNewSession: $showingNewSession
            )
            
            if showingActionSheet, let session = actionSheetSession {
                CounterActionSheet(
                    isPresented: $showingActionSheet,
                    session: session,
                    sessionManager: sessionManager,
                    showingRenameAlert: $showingRenameAlert
                )
            }
        }
        .fullScreenCover(isPresented: $showingNewSession) {
            NewSessionView(
                sessionManager: sessionManager,
                isPresented: $showingNewSession
            )
        }
    }
}


#Preview {
    ContentView()
}
