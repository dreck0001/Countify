//
//  CountSessionManager.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import Foundation

class CountSessionManager: ObservableObject {
    @Published var sessions: [CountSession] = []
    @Published var hapticEnabled: Bool = true
    @Published var allowNegatives: Bool = false
    
    private let saveKey = "CountSessions"
    
    init() {
        loadSessions()
    }
    
    func saveSession(_ session: CountSession) {
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        saveSessions()
    }
    
    func deleteSession(at indexSet: IndexSet) {
        sessions.remove(atOffsets: indexSet)
        saveSessions()
    }
    
    private func saveSessions() {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadSessions() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([CountSession].self, from: data) {
            sessions = decoded
        }
    }
}
