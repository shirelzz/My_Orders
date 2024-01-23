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
//    @State private var path: NavigationPath = NavigationManager.shared.path
//    @EnvironmentObject var navigationManager: NavigationManager
//    @EnvironmentObject var router: Router

    var body: some View {
        
//        let width = UIScreen.main.bounds.width - 32
        let height = UIScreen.main.bounds.height - 32
        
        NavigationStack() { //path: $path
            
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
                
//                Button {
//                    user = User(uid: UUID().uuidString, role: UserRole.vendor, vendorType: VendorType.food)
//                    isFoodPressed.toggle()
//                    
//                    resetButtons(isFood: isFoodPressed)
//                    
//                    
//                } label: {
//                    Text("Food")
//                        .frame(minWidth: 0, maxWidth: .infinity)
//                        .frame(width: width, height: 50)
//                        .foregroundColor(isFoodPressed ? Color.accentColor :  .white)
//                        .background(isFoodPressed ? Color.white : Color.accentColor.opacity(0.9))
//                        .cornerRadius(30)
//                        .padding(.horizontal)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 30)
//                                .stroke(Color.accentColor, lineWidth: 1.5)
//                                .frame(width: width, height: 50)
//                        )
//                }
//                .sheet(isPresented: $showContentView, content: {
//                    ContentView()
//                })
//                .frame(minWidth: 0 , maxWidth: .infinity)
//                .frame(height: 50)
//                .padding()
//                .buttonStyle(CustomButtonStyle(isPressed: isPressed))
//                .onTapGesture {
//                    isPressed.toggle()
//                }

                
                CustomButton(title: "Food", isPressed: $isFoodPressed, action: {
                                vendorType = .food
                                resetButtons(isFood: true)
                    
                    //                    UserManager.shared.saveUser(user: user)
                    //                    hasLaunchedBefore = true
//                                        showContentView = true
                })
//                .navigationDestination(isPresented: $showContentView) {
//                    ContentView()
//                }
                
                CustomButton(title: "Beauty", isPressed: $isBeautyPressed, action: {
                    vendorType = .beauty
                    resetButtons(isBeauty: true)
                    
                    //                    UserManager.shared.saveUser(user: user)
                    //                    hasLaunchedBefore = true
                    //                    showContentView = true
                })
                
                Text("or")
                    .foregroundColor(.gray)
                    .padding()
                
                CustomButton(title: "Other", isPressed: $isOtherPressed, action: {
                    vendorType = .other
                    resetButtons(isOther: true)
                    
                    //                    UserManager.shared.saveUser(user: user)
                    //                    hasLaunchedBefore = true
                    //                    showContentView = true
                })
                


                
                Spacer(minLength: height / 7)
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true) // Hide default back button
//            .navigationBarItems(
//                leading: Button("Back") {
//                // isVendor = false  // Navigate back to UserRoleView
//                }
//                ,
//                trailing: Button("Done") {
//                    
//                }
//            )
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Back") {
//                            if path.count > 0 {
////                                path = NavigationPath()
//                                 path.removeLast(1)
//                            }
//                            router.navigateBack()

//                            router.navigate(to: .welcome)
                            isBackPressed = true
                            
                        }
                        .navigationDestination(isPresented: $isBackPressed) {
                            UserRoleView()
                        }
                        
//                        .navigationDestination(isPresented: $showBackView, destination: {
//                            UserRoleView()
//                        })
                        
                        Spacer()
                        
                        Button("Continue") {
                            user = User(uid: UUID().uuidString, role: .vendor, vendorType: vendorType)
                            UserManager.shared.saveUser(user: user)
                            
                            let vendor = Vendor(uid: user.uid, vendorType: vendorType, businessID: "", businessName: "", businessAddress: "", businessPhone: "")
                            VendorManager.shared.saveVendor(vendor: vendor)
                            
                            showBusinessDetailsView = true
//                            hasLaunchedBefore = true
//                            showContentView = true
//                            router.navigate(to: .bussinessDetailsView)

//                            Router.shared.changeRoute(RoutePath(.bussinessDetailsView))
                        }
                        .navigationDestination(isPresented: $showBusinessDetailsView, destination: {
                            BusinessDetailsView()
                        })
                        .disabled(!isFoodPressed && !isBeautyPressed && !isOtherPressed)
//                        .task {
//                            Router.shared.changeRoute = changeRoute
//                            Router.shared.backRoute = backRoute
//                        }
                    }
                }
            }
//            .navigationDestination(for: RoutePath.self) { route in
//                switch route.route {
//                case .customerContent:
//                    Text("customerContent")
//                    
//                case .vendorType:
//                    Text("vendorType")
//                    
//                case .bussinessDetailsView:
//    //                Router.shared.backRoute()
//                    BussinessDetailsView()
//    //                Text("")
//                    
//                case .userRole:
//    //                Router.shared.backRoute()
//                    UserRoleView()
//    //                Text("")
//
//                case .contentView:
//                    Text("contentView")
//
////                    ContentView()
//
//                case .none:
//                    EmptyView()
////                    Text("none")
//
//                }
//            }
        }
        .navigationBarHidden(true)

    }
    
    func resetButtons(isFood: Bool = false, isBeauty: Bool = false, isOther: Bool = false) {
        isFoodPressed = isFood
        isBeautyPressed = isBeauty
        isOtherPressed = isOther
    }
//    
//    // MARK: Route
//        func changeRoute(_ route: RoutePath) {
//            path.append(route)
//        }
//
//        func backRoute() {
//            path.removeLast()
//        }
}

#Preview {
    VendorTypeView()
}
