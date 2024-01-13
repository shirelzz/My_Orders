//
//  UserRoleView.swift
//  My Orders
//
//  Created by שיראל זכריה on 13/01/2024.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Firebase
import FirebaseAuth

struct UserRoleView: View {
    
    @State private var isVendor = false
    @State private var isCustomer = false
//    @EnvironmentObject var authState: AuthState
    
    
    var body: some View {
        
        let guestWidth = UIScreen.main.bounds.width - 32
        let height = UIScreen.main.bounds.height - 32
        
        
        NavigationView {
            
            VStack {
                
                Image("aesthetic")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: height/3)
                
                Spacer()
                
                Text("Choose an option:")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
                
                Button {
                    
                    isVendor = true
                    
                } label: {
                    Text("Vendor")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(width: guestWidth, height: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor.opacity(0.9))
                        .cornerRadius(30)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $isVendor, content: {
                    VendorTypeView()
                })
                .frame(minWidth: 0 , maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                
                
                Button {
                    
                    let user = User(uid: UUID().uuidString, role: UserRole.customer, vendorType: nil)
                    
                    UserManager.shared.saveUser(user: user)

                    isCustomer = true
                    
                } label: {
                    Text("Customer")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(width: guestWidth, height: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor.opacity(0.9))
                        .cornerRadius(30)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $isCustomer, content: {
                    CustomerContentView()
                })
                
                Spacer(minLength: height / 7)
            }
            .navigationBarHidden(true)
        }
    }
    
}
    struct UserRoleView_Previews: PreviewProvider {
        static var previews: some View {
            UserRoleView()
        }
    }
