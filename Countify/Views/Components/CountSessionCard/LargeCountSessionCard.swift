//
//  LargeCountSessionCard.swift
//  Countify
//
//  Created by Throw Catchers on 2/22/25.
//

import SwiftUI

struct LargeCountSessionCard: View {
    let session: CountSession
    let onEllipsisPress: () -> Void
    
    // Glass effect background for cards
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.primary.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(Color.primary.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }
    
    private func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day], from: session.date, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour) \(hour == 1 ? "hour" : "hours") ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute) \(minute == 1 ? "min" : "mins") ago"
        } else {
            return "Just now"
        }
    }
    
    var body: some View {
        
        HStack(spacing: 0) {
            Text("\(session.count)")
                .font(.system(size: 35, weight: .bold))
                .minimumScaleFactor(0.6)
                .lineLimit(1)
//                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width * 2/7)
            
            Divider()
            
            VStack( spacing: 15) {
                Text(session.name)
                    .font(.system(size: 20, weight: .semibold))
//                    .foregroundColor(.white)
                    
                
                // Feature indicators as simple icons in a row
                HStack(spacing: 15) {
                    if session.stepSize > 1 {
                        FeatureTag(icon: "arrow.up.arrow.down", text: "")
                    }
                    
                    if session.upperLimit != nil || session.lowerLimit != nil {
                        FeatureTag(icon: "ruler", text: "")
                    }
                    
                    if session.allowNegatives {
                        FeatureTag(icon: "plusminus", text: "")
                    }
                    
                    if session.hapticEnabled {
                        FeatureTag(icon: "waveform", text: "")
                    }
                }
                
                Text(timeAgo())
                    .font(.caption)
                    .foregroundColor(.secondary.opacity(0.8))
            }
            .frame(width: UIScreen.main.bounds.width * 4/7)
            
            Divider()

            Button(action: onEllipsisPress) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.8))
                    .padding(10)
                    .contentShape(Rectangle())
            }
                .frame(width: UIScreen.main.bounds.width * 1/7)
        }
        .frame(height: 120)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .background(cardBackground)
    }
}


#Preview {
    LargeCountSessionCard(
        session: CountSession(name: "Daily Steps", count: 8344490, hapticEnabled: true, allowNegatives: true,
                stepSize: 5, upperLimit: 10000, lowerLimit: 0), onEllipsisPress: { }
    )
}
