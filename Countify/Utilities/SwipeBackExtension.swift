//
//  SwipeBackExtension.swift
//  Countify
//
//  Created by Throw Catchers on 2/26/25.
//

import SwiftUI

extension View {
    func swipeToGoBack(dismiss: DismissAction) -> some View {
        modifier(SwipeBackModifier(dismiss: dismiss))
    }
}

struct SwipeBackModifier: ViewModifier {
    let dismiss: DismissAction
    @State private var dragOffset: CGFloat = 0
    @State private var startX: CGFloat? = nil
    
    func body(content: Content) -> some View {
        content
            .offset(x: dragOffset)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1), value: dragOffset)
            .gesture(
                DragGesture(minimumDistance: 5)
                    .onChanged { gesture in
                        // Initialize startX if needed
                        if startX == nil {
                            startX = gesture.startLocation.x
                        }
                        
                        // Only activate when starting from the left edge region (first 1/50 of screen width)
                        let leftEdgeRegion = UIScreen.main.bounds.width / 50
                        if startX ?? 0 < leftEdgeRegion {
                            // Calculate the drag amount (only allow rightward movement)
                            let dragAmount = max(0, gesture.translation.width)
                            dragOffset = dragAmount
                            
                            // If we have a navigation controller, update its toolbar opacity
                            updateToolbarOpacity(progress: dragAmount / UIScreen.main.bounds.width)
                        }
                    }
                    .onEnded { gesture in
                        // Reset startX
                        defer { startX = nil }
                        
                        // Determine if we should dismiss
                        let velocity = gesture.predictedEndTranslation.width - gesture.translation.width
                        let distanceThreshold = UIScreen.main.bounds.width * 0.3
                        let velocityThreshold: CGFloat = 300
                        
                        let shouldDismiss = dragOffset > distanceThreshold ||
                                          (dragOffset > 50 && velocity > velocityThreshold)
                        
                        if shouldDismiss {
                            // Animate off screen then dismiss
                            withAnimation(.easeOut(duration: 0.2)) {
                                dragOffset = UIScreen.main.bounds.width
                            }
                            
                            // Slight delay to allow animation to complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                dismiss()
                            }
                        } else {
                            // Return to original position
                            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.1)) {
                                dragOffset = 0
                                // Reset toolbar opacity
                                updateToolbarOpacity(progress: 0)
                            }
                        }
                    }
            )
            .onAppear {
                // Reset state
                dragOffset = 0
                startX = nil
                
                // Ensure toolbars are visible
                updateToolbarOpacity(progress: 0)
            }
    }
    
    // Helper method to update toolbar opacity
    private func updateToolbarOpacity(progress: CGFloat) {
        // Find all navigation controllers in the app
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let rootController = windowScene.windows.first?.rootViewController {
                updateToolbarOpacity(for: rootController, progress: progress)
            }
        }
    }
    
    // Recursively update toolbar opacity for all navigation controllers
    private func updateToolbarOpacity(for viewController: UIViewController, progress: CGFloat) {
        if let navController = viewController as? UINavigationController {
            // Update this navigation controller's toolbar
            navController.navigationBar.subviews.forEach { view in
                // Skip the navigation bar background
                if !NSStringFromClass(type(of: view)).contains("Background") &&
                   !NSStringFromClass(type(of: view)).contains("UIBarBackground") {
                    view.alpha = 1.0 - progress
                }
            }
            
            // Also update for the visible view controller
            if let visibleVC = navController.visibleViewController {
                updateToolbarOpacity(for: visibleVC, progress: progress)
            }
        }
        
        // Update for child view controllers
        for child in viewController.children {
            if child != viewController.presentedViewController {
                updateToolbarOpacity(for: child, progress: progress)
            }
        }
    }
}
