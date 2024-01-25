//
//  VendorTypeView.swift
//  My Orders
//
//  Created by שיראל זכריה on 13/01/2024.
//

import SwiftUI

struct VendorTypeView: View {
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showBusinessDetailsView = false
    @State private var isBackPressed = false
    @State private var isFoodPressed = false
    @State private var isBeautyPressed = false
    @State private var isOtherPressed = false
    @State private var user: User = User()
    @State private var vendorType: VendorType = .none
    @ObservedObject private var userManager = UserManager.shared
    @ObservedObject private var vendorManager = VendorManager.shared

    var body: some View {
        
        let height = HelperFunctions.getHeight()
        
        NavigationStack() {
            
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
                
                CustomButton(title: "Food", isPressed: $isFoodPressed, action: {
                                vendorType = .food
                                resetButtons(isFood: true)
                })
                
                CustomButton(title: "Beauty", isPressed: $isBeautyPressed, action: {
                    vendorType = .beauty
                    resetButtons(isBeauty: true)
                })
                
                Text("or")
                    .foregroundColor(.gray)
                    .padding()
                
                CustomButton(title: "Other", isPressed: $isOtherPressed, action: {
                    vendorType = .other
                    resetButtons(isOther: true)
                })
                


                
                Spacer(minLength: height / 7)
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true) // Hide default back button
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Back") {
                            isBackPressed = true
                            
                        }
                        .navigationDestination(isPresented: $isBackPressed) {
                            UserRoleView()
                        }
                        
                        Spacer()
                        
                        Button("Continue") {
                            user = User(uid: UUID().uuidString, role: .vendor) //, vendorType: vendorType
                            UserManager.shared.saveUser(user: user)
                            
                            let vendor = Vendor(uid: user.uid, vendorType: vendorType, businessID: "", businessName: "", businessAddress: "", businessPhone: "")
                            VendorManager.shared.saveVendor(vendor: vendor)
                            
                            showBusinessDetailsView = true

                        }
                        .navigationDestination(isPresented: $showBusinessDetailsView, destination: {
                            BusinessDetailsView()
                        })
                        .disabled(!isFoodPressed && !isBeautyPressed && !isOtherPressed)
                    }
                }
            }

        }
        .navigationBarHidden(true)

    }
    
    func resetButtons(isFood: Bool = false, isBeauty: Bool = false, isOther: Bool = false) {
        isFoodPressed = isFood
        isBeautyPressed = isBeauty
        isOtherPressed = isOther
    }
}

#Preview {
    VendorTypeView()
}
