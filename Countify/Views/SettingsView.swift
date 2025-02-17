//
//  SettingsView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var sessionManager: CountSessionManager
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle("Default Vibration", isOn: $sessionManager.hapticEnabled)
                    Toggle("Default Allow Negative Numbers", isOn: $sessionManager.allowNegatives)
                } header: {
                    Text("Default Settings")
                }
                
                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

//#Preview {
//    SettingsView()
//}
