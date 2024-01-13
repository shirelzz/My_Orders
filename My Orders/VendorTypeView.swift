//
//  VendorTypeView.swift
//  My Orders
//
//  Created by שיראל זכריה on 13/01/2024.
//

import SwiftUI

struct VendorTypeView: View {
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showContentView = false
    
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
                    let user = User(uid: UUID().uuidString, role: UserRole.vendor, vendorType: VendorType.food)
                    
                    UserManager.shared.saveUser(user: user)
                    showContentView = true
                    
                } label: {
                    Text("Food")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(width: guestWidth, height: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor.opacity(0.9))
                        .cornerRadius(30)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $showContentView, content: {
                    ContentView()
                })
                .frame(minWidth: 0 , maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                
                Button {
                    
                    let user = User(uid: UUID().uuidString, role: UserRole.vendor, vendorType: VendorType.beauty)
                    
                    UserManager.shared.saveUser(user: user)
                    showContentView = true
                    
                } label: {
                    Text("Beauty")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(width: guestWidth, height: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor.opacity(0.9))
                        .cornerRadius(30)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $showContentView, content: {
                    ContentView()
                })
                .frame(minWidth: 0 , maxWidth: .infinity)
                .frame(height: 50)
                .padding()
                
                
                Text("or")
                    .foregroundColor(.gray)
                    .padding()
                
                Button {
                    
                    let user = User(uid: UUID().uuidString, role: UserRole.vendor, vendorType: VendorType.other)
                    
                    UserManager.shared.saveUser2DB(user)
                    showContentView = true
                    
                } label: {
                    Text("Other")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .frame(width: guestWidth, height: 50)
                        .foregroundColor(.white)
                        .background(Color.accentColor.opacity(0.9))
                        .cornerRadius(30)
                        .padding(.horizontal)
                }
                .sheet(isPresented: $showContentView, content: {
                    ContentView()
                })
                
                Spacer(minLength: height / 7)
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    VendorTypeView()
}
