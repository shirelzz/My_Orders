//
//  LaunchView.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/11/2023.
//

import SwiftUI

struct LaunchView: View {
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        
        let imageName = colorScheme == .dark ? "AppIconDark" : "StoreLogo"

        
        Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
        }
}

#Preview {
    LaunchView()
}
