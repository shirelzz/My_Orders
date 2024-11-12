//
//  CustomSectionView.swift
//  My Orders
//
//  Created by שיראל זכריה on 20/09/2024.
//

import SwiftUI

struct CustomSectionView: View {
    
    var title: String
    var address: String
    var sfSymbol: String
    
    @State private var isWiggling = false
    
    var body: some View {
        HStack(spacing: 8) {
            // SF Symbol with wiggle animation
            Image(systemName: sfSymbol)
                .foregroundColor(.yellow)
                .rotationEffect(.degrees(isWiggling ? -10 : 10))
                .animation(
                    Animation.easeInOut(duration: 0.15)
                        .repeatForever(autoreverses: true),
                    value: isWiggling
                )
                .onAppear {
                    isWiggling = true
                }

            VStack(alignment: .leading, spacing: 4) {
                // Text: Dynamic title
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                // Address text
                Text(address)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
//        .padding(.horizontal)
    }
}

struct CustomSectionView_Previews: PreviewProvider {
    static var previews: some View {
        CustomSectionView(
            title: "Deliver to",
            address: "221B Baker Street, London, United Kingdom",
            sfSymbol: "mappin.and.ellipse"
        )
    }
}
