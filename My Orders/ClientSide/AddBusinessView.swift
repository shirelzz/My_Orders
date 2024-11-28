//
//  AddBusinessView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/01/2024.
//

import SwiftUI

struct AddBusinessView: View {
    
    @State private var code = ""
    @State private var validCode = false

    
    var body: some View {
        TextField("Enter code", text: $code)
            .onChange(of: code) { _ in
                validateCode()
            }
        
        Button {
            if validCode {
                
            }
        } label: {
            Text("Save")
        }
        .buttonStyle(.borderedProminent)

    }
    
    func validateCode()
    {
        
    }
}

#Preview {
    AddBusinessView()
}
