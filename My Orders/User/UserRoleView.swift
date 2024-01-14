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
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var isVendorPressed = false
    @State private var isCustomerPressed = false
    @State private var showVendorTypeView = false
    @State private var showCustomerContent = false
    @State private var path: NavigationPath = NavigationPath()
    
    var body: some View {
        
        let height = UIScreen.main.bounds.height - 32
        
        
        NavigationStack(path: $path) {
            
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
                
//                NavigationLink(destination: VendorTypeView()) {
//                    Label {
//                        Text("Vendor")
//                    } icon: {
//                        
//                    }
////                    EmptyView()
//
//                }
//                .frame(minWidth: 0, maxWidth: .infinity)
//                .frame(width: width, height: 50)
//                .foregroundColor(.white)
//                .background(Color.accentColor.opacity(0.9))
//                .cornerRadius(30)
//                .padding(.horizontal)
//                .onTapGesture {
//                    isVendorPressed = true
//                    isPressed = true
//                }
//                .buttonStyle(CustomButtonStyle(isPressed: isPressed))
//                
                
                
                
//                Button {
//                    
//                    isVendor = true
//                    
//                } label: {
//                    Text("Vendor")
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .frame(width: width, height: 50)
//                        .foregroundColor(.white)
//                        .background(Color.accentColor.opacity(0.9))
//                        .cornerRadius(30)
//                        .padding(.horizontal)
//                }
//                .sheet(isPresented: $isVendor, content: {
//                    VendorTypeView()
//                })
//                .frame(minWidth: 0 , maxWidth: .infinity)
//                .frame(height: 50)
//                .padding()
                
                CustomButton(title: "Vendor", isPressed: $isVendorPressed) {
                    isVendorPressed.toggle()
                    resetButtons(isVendor: isVendorPressed)
                }
                
                
//                Button {
//                    
//                    let user = User(uid: UUID().uuidString, role: UserRole.customer, vendorType: nil)
//                    
//                    UserManager.shared.saveUser(user: user)
//                    hasLaunchedBefore = true
//                    isCustomer = true
//                    
//                } label: {
//                    Text("Customer")
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .frame(width: width, height: 50)
//                        .foregroundColor(.white)
//                        .background(Color.accentColor.opacity(0.9))
//                        .cornerRadius(30)
//                        .padding(.horizontal)
//                }
//                .sheet(isPresented: $isCustomer, content: {
//                    CustomerContentView()
//                })
//                .buttonStyle(CustomButtonStyle())
                
                CustomButton(title: "Customer", isPressed: $isCustomerPressed) {
                    isCustomerPressed.toggle()
                    resetButtons(isCustomer: isCustomerPressed)
                    
                }
                
                
                Spacer(minLength: height / 7)
            }
            .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
//                        Button("Back") {
//                            showBackView = true
//                        }
//                        .navigationDestination(isPresented: $showBackView, destination: {
//                            UserRoleView()
//                        })
                        
                        Spacer()
                        
                        Button("Continue") {
                            if isVendorPressed {
                                showVendorTypeView = true
                            }
                            else if isCustomerPressed {
                                
                                let user = User(uid: UUID().uuidString, role: UserRole.customer, vendorType: nil)
                                UserManager.shared.saveUser(user: user)
                                
                                hasLaunchedBefore = true
                                showCustomerContent = true
                            }
                        }
                        .navigationDestination(isPresented: $showVendorTypeView, destination: {
                            VendorTypeView()
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
