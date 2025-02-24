//
//  BottomRoundedRectangle.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/11/2024.
//

import Foundation
import SwiftUI

// Custom Shape with Bottom-Only Corner Radius
struct BottomRoundedRectangle: Shape {
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Start at the top-left corner
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        
        // Draw line across the top (no corner radius)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        
        // Draw line down the right side to start the rounded corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        
        // Bottom-right corner arc
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .zero,
                    endAngle: .degrees(90),
                    clockwise: false)
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        
        // Bottom-left corner arc
        path.addArc(center: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY - cornerRadius),
                    radius: cornerRadius,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        
        // Close the path along the left side
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        
        return path
    }
}

