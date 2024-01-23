//
//  CustomerContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 13/01/2024.
//

import SwiftUI

struct CustomerContentView: View {
    
//    @State private var path: NavigationPath = NavigationManager.shared.path
//    @ObservedObject var router = Router()
    @EnvironmentObject var router: Router

    var body: some View {
        
        NavigationStack() { //path: $router.navPath
            
            Text("Hello, World!")
            
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    CustomerContentView()
}
