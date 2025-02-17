//
//  CountSession.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import Foundation

struct CountSession: Identifiable, Codable {
    let id: UUID
    var name: String
    var count: Int
    var date: Date
    var hapticEnabled: Bool
    var allowNegatives: Bool
    
    init(id: UUID = UUID(),
         name: String = "New Count",
         count: Int = 0,
         date: Date = Date(),
         hapticEnabled: Bool = true,
         allowNegatives: Bool = false) {
        self.id = id
        self.name = name
        self.count = count
        self.date = date
        self.hapticEnabled = hapticEnabled
        self.allowNegatives = allowNegatives
        self.allowNegatives = allowNegatives

    }
}
