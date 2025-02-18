//
//  CountSessionListView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct CountSessionListView: View {
    @ObservedObject var sessionManager: CountSessionManager
    @State private var showingNewSession = false
    
    var body: some View {
        NavigationView {
            Group {
                if sessionManager.sessions.isEmpty {
                    EmptyStateView(action: { showingNewSession = true })
                } else {
                    List {
                        ForEach(sessionManager.sessions.sorted(by: { $0.date > $1.date })) { session in
                            NavigationLink(destination: CountingStepperView(session: session, sessionManager: sessionManager)) {
                                SessionRowView(session: session)
                            }
                        }
                        .onDelete(perform: sessionManager.deleteSession)
                    }
                }
            }
            .navigationTitle("Countify")
            .toolbar {
                Button(action: { showingNewSession = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $showingNewSession) {
                NewSessionView(sessionManager: sessionManager, isPresented: $showingNewSession)
            }
        }
    }
}

#Preview {
    CountSessionListView(sessionManager: CountSessionManager())
}
