//
//  CounterControlsView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct CounterControlsView: View {
    @Binding var session: CountSession
    @Binding var isIncrementing: Bool
    let onSave: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 60)
                .fill(Color.gray.opacity(0.5))
                .frame(height: 120)
                .padding(.horizontal, 20)
            
            HStack {
                Spacer()
                
                DecrementButton(session: $session, isIncrementing: $isIncrementing, onSave: onSave)
                
                Spacer()
                Spacer()
                
                IncrementButton(session: $session, isIncrementing: $isIncrementing, onSave: onSave)
                
                Spacer()
            }
        }
        .padding(.bottom, 30)
    }
}

//#Preview {
//    CounterControlsView()
//}
