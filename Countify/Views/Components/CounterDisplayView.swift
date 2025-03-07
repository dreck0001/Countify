//
//  CounterDisplayView.swift
//  Countify
//
//  Created by Throw Catchers on 2/20/25.
//

import SwiftUI

struct CounterDisplayView: View {
    let count: Int
    let isIncrementing: Bool
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Text("\(count)")
            .contentTransition(.numericText(countsDown: isIncrementing))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: count)
            .minimumScaleFactor(0.3)
            .lineLimit(1)
            // Adjust font size based on device size class
            .font(.system(size: horizontalSizeClass == .regular ? 250 : 200, weight: .bold))
            .frame(height: UIScreen.main.bounds.height / (horizontalSizeClass == .regular ? 2.5 : 3))
            .frame(maxWidth: .infinity)
    }
}


#Preview {
    ScrollView {
        VStack {
            CounterDisplayView(count: 0, isIncrementing: true)
            CounterDisplayView(count: 9999, isIncrementing: true)
            CounterDisplayView(count: 999999, isIncrementing: true)
        }
    }
}
