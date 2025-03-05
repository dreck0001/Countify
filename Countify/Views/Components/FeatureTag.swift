//
//  FeatureTag.swift
//  Countify
//
//  Created by Throw Catchers on 2/21/25.
//

import SwiftUI

// Icon-only feature indicator used in CountSessionListView
struct FeatureTag: View {
    let icon: String
    let text: String // Kept for reference but not always displayed
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
            
            if !text.isEmpty {
                Text(text)
                    .font(.system(size: 12))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Circle()
                .fill(Color.primary.opacity(0.08))
        )
        .foregroundColor(.primary.opacity(0.7))
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    HStack {
        FeatureTag(icon: "arrow.up.arrow.down", text: "5")
        FeatureTag(icon: "hand.tap", text: "")
        FeatureTag(icon: "plusminus", text: "")
        FeatureTag(icon: "ruler", text: "")
    }
    .padding()
}
