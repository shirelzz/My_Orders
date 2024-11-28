//
//  CustomSectionView.swift
//  My Orders
//
//  Created by שיראל זכריה on 20/09/2024.
//

import SwiftUI

struct CustomSectionView: View {
    
    var title: String
    var description: String
    var sfSymbol: String
    var sfSymbolColor: Color

    
    @State private var isWiggling = false
    
    @Environment(\.colorScheme) var colorScheme
    
    // Set the color based on the color scheme
    var textColor: Color {
        colorScheme == .light ? Color.black : Color.white
    }
    
    var body: some View {
        HStack(spacing: 8) {
            
            // SF Symbol with wiggle animation
            Image(systemName: sfSymbol)
                .foregroundColor(sfSymbolColor)
                .rotationEffect(.degrees(isWiggling ? -10 : 10))
                .animation(
                    Animation.easeInOut(duration: 0.15)
//                        .repeatForever(autoreverses: true),
                        .repeatCount(6, autoreverses: true),
                    value: isWiggling
                )
                .onAppear {
                    isWiggling = true
                }

            VStack(alignment: .leading, spacing: 4) {

                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textColor)
                
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(textColor)
            }
            
            Spacer()
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.clear)
        )
        .contextMenu {
            Button(action: {
                UIPasteboard.general.string = description
            }) {
                Text("Copy")
                Image(systemName: "doc.on.doc")
            }
        }
    }
}

struct CustomSectionView_Previews: PreviewProvider {
    static var previews: some View {
        CustomSectionView(
            title: "Deliver to",
            description: "221B Baker Street, London, United Kingdom",
            sfSymbol: "mappin.and.ellipse",
            sfSymbolColor: Color.yellow
        )
    }
}
