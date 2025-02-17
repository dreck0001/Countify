//
//  SessionRowView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct SessionRowView: View {
    let session: CountSession
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(session.name)
                .font(.headline)
            HStack {
                Text("Count: \(session.count)")
                    .foregroundColor(.secondary)
                Spacer()
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
