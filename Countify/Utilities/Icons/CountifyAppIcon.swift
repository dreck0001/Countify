//
//  CountifyAppIcon.swift
//  Countify
//
//  Created by Throw Catchers on 2/27/25.
//

import SwiftUI

struct CountifyAppIcon: View {
    @Binding var session: CountSession
    @Binding var isIncrementing: Bool
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                EnhancedDecrementButton(session: $session, isIncrementing: $isIncrementing, onSave: onSave)
                    .offset(x: 30, y: 0)
                EnhancedIncrementButton(session: $session, isIncrementing: $isIncrementing, onSave: onSave)
                Spacer()
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    CountifyAppIcon(
        session: .constant(CountSession(name: "Counter", count: 5)),
        isIncrementing: .constant(true),
        onSave: {}
    )
}
