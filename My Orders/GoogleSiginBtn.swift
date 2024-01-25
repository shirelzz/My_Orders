//
//  GoogleSiginBtn.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/12/2023.
//

import Foundation
import SwiftUI

struct GoogleSiginBtn: View {
    var action: () -> Void
    
    var body: some View {
        
        let width = HelperFunctions.getWidth()
        
        Button(action: action) {
                    HStack {
                        Image("googleLogo")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Sign in With Google")
                            .foregroundColor(.black)
                            .font(.system(size: 18))
                    }
                    .padding() // Adjust padding to your liking
                    .frame(width: width, height: 45)
                    .background(Color.white)
                    .cornerRadius(30)
                    .shadow(color: .black.opacity(0.6), radius: 5, x: 0, y: 2) // Adjust shadow parameters
                }
        .frame(minWidth: 0, maxWidth: .infinity)

        
//        Button {
//            action()
//        } label: {
//            ZStack{
//                    
//                HStack{
//                    Image("googleLogo")
//                        .resizable()
//                        .frame(width: 23, height: 23)
//
//                    Text("Sign in With Google")
//                        .foregroundColor(.black)
//                        
//                }
//                    .background(Color.white)
//            }
//            
//        }
////        .frame(minWidth: 200, maxWidth: .infinity)
////        .frame(height: 50)
//        .cornerRadius(30)
//        .shadow(color: .black.opacity(0.8), radius: 60, x: 0, y: 16)
//        .padding(.horizontal)


    }
}

struct GoogleSiginBtn_Previews: PreviewProvider {
    static var previews: some View {
        GoogleSiginBtn(action: {})
    }
}
