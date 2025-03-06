//
//  CountifyApp.swift
//  Countify
//
//  Created by Throw Catchers on 2/16/25.
//

import SwiftUI

@main
struct CountifyApp: App {
    init() {
        // Set the global tint color to adapt to the interface style
        UINavigationBar.appearance().tintColor = UIColor { (traitCollection: UITraitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        
        // Set the default appearance for all controls
        let tintColorHandler = { (traitCollection: UITraitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .dark ? .white : .black
        }
        
        UIView.appearance().tintColor = UIColor(dynamicProvider: tintColorHandler)
        UINavigationBar.appearance().tintColor = UIColor(dynamicProvider: tintColorHandler)
        UITabBar.appearance().tintColor = UIColor(dynamicProvider: tintColorHandler)
        UIBarButtonItem.appearance().tintColor = UIColor(dynamicProvider: tintColorHandler)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
