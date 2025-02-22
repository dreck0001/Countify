//
//  CountSessionManager.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import Foundation

class CountSessionManager: ObservableObject {
    @Published var sessions: [CountSession] = []
    
    // Default settings are still maintained but used only for new sessions
    @Published var hapticEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(hapticEnabled, forKey: "DefaultHapticEnabled")
        }
    }
    
    @Published var allowNegatives: Bool = false {
        didSet {
            UserDefaults.standard.set(allowNegatives, forKey: "DefaultAllowNegatives")
        }
    }
    
    private let saveKey = "CountSessions"
    
    init() {
        loadSessions()
        
        // Load default settings
        hapticEnabled = UserDefaults.standard.bool(forKey: "DefaultHapticEnabled")
        allowNegatives = UserDefaults.standard.bool(forKey: "DefaultAllowNegatives")
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
