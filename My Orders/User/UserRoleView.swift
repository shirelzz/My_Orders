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

// read: https://medium.com/@mdyamin/navigationstack-revolution-of-nested-navigation-with-swiftui-7a00782b974b

struct UserRoleView: View {
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var isVendorPressed = false
    @State private var isCustomerPressed = false
//    @State private var showVendorTypeView = false
    @State private var showBusinessDetailsView = false
    @State private var showCustomerContent = false
    @State private var isBackPressed = false
    @ObservedObject private var userManager = UserManager.shared
    @ObservedObject private var vendorManager = VendorManager.shared

    var body: some View {
        
        let height = HelperFunctions.getHeight()
        
        
        NavigationStack() {
            
            VStack {
                
//                Image("aesthetic")
//                    .resizable()
//                    .scaledToFill()
//                    .edgesIgnoringSafeArea(.top)
//                    .frame(height: height/3)
                
                Label("", image: "aesthetic")
                    .frame(height: height/4)

                Spacer()
                
                Text("Choose an option:")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding(.top, 40)
                
                VStack (spacing: 10){

                CustomButton(title: "Vendor", isPressed: $isVendorPressed) {
                    isVendorPressed.toggle()
                    resetButtons(isVendor: isVendorPressed)
                }
                
                CustomButton(title: "Customer", isPressed: $isCustomerPressed) {
                    isCustomerPressed.toggle()
                    resetButtons(isCustomer: isCustomerPressed)
                    
                }
            }
            .padding()
                
                
                Spacer(minLength: height / 7)
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Back") {
                            isBackPressed = true
                        }
                        .navigationDestination(isPresented: $isBackPressed) {
                            WelcomeView()
                        }
                        
                        Spacer()
                        
                        Button("Continue") {
                            if isVendorPressed {
//                                showVendorTypeView = true
                                showBusinessDetailsView = true
                            }
                            else if isCustomerPressed {
                                
                                let user = User(uid: UUID().uuidString, role: UserRole.customer) //, vendorType: nil
                                userManager.saveUser(user: user)
                                
                                hasLaunchedBefore = true
                                showCustomerContent = true

                            }
                        }
//                        .navigationDestination(isPresented: $showVendorTypeView, destination: {
//                            VendorTypeView()
//                        })
                        .navigationDestination(isPresented: $showBusinessDetailsView, destination: {
                            BusinessDetailsView()
                        })
                        .navigationDestination(isPresented: $showCustomerContent, destination: {
                            CustomerContentView()
                        })
                        .disabled(!isVendorPressed && !isCustomerPressed)
                    }
                }
            }
        }
    }
    
    func resetButtons(isVendor: Bool = false, isCustomer: Bool = false) {
        isVendorPressed = isVendor
        isCustomerPressed = isCustomer
    }
}

struct UserRoleView_Previews: PreviewProvider {
    static var previews: some View {
        UserRoleView()
    }
}
