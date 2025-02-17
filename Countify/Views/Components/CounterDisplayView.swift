//
//  CounterDisplayView.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

struct CounterDisplayView: View {
    let count: Int
    let isIncrementing: Bool
    
    var body: some View {
        ZStack {
            Text("\(count)")
                .font(.system(size: 200, weight: .bold))
                .contentTransition(.numericText(countsDown: !isIncrementing))
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
            
            RoundedRectangle(cornerRadius: 60)
                .fill(Color.gray.opacity(0.5))
                .frame(height: 300)
                .padding(.horizontal, 20)
        }
    }
}

//#Preview {
//    CounterDisplayView()
//}
