//
//  MainView.swift
//  My Orders
//
//  Created by שיראל זכריה on 27/11/2023.
//

import SwiftUI


struct MainView: View {
    
    @State private var showLogo = true

    var body: some View {

        ZStack {
            if showLogo {
                LaunchView()
                    .onAppear {
                        // Add any additional setup code if needed
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showLogo = false
                            }
                        }
                    }
            } else {
                ContentView()
            }
        }
    }
}

#Preview {
    MainView()
}
