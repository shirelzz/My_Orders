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
    @State private var showVendorTypeView = false
    @State private var showCustomerContent = false
    @State private var isBackPressed = false
    @ObservedObject private var userManager = UserManager.shared
    @ObservedObject private var vendorManager = VendorManager.shared
//    @State private var path: NavigationPath = NavigationManager.shared.path
//    @EnvironmentObject var router: Router

    var body: some View {
        
        let height = UIScreen.main.bounds.height - 32
        
        
        NavigationStack() { //path: $path
            
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
            }
            .padding()
                
                
                Spacer(minLength: height / 7)
            }
            .navigationBarHidden(true)
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
                            WelcomeView()
                        }
//                                                Button("Back") {
//                                                    showBackView = true
//                                                }
//                                                .navigationDestination(isPresented: $showBackView, destination: {
//                                                    UserRoleView()
//                                                })
                        
                        Spacer()
                        
                        Button("Continue") {
                            if isVendorPressed {
                                showVendorTypeView = true
//                                path.append(Routes.vendorType)
//                                router.navigate(to: .vendorType)
//                                Router.shared.changeRoute(RoutePath(.vendorType))
                                
                            }
                            else if isCustomerPressed {
                                
                                let user = User(uid: UUID().uuidString, role: UserRole.customer, vendorType: nil)
                                userManager.saveUser(user: user)
                                
                                hasLaunchedBefore = true
                                showCustomerContent = true
//                                router.navigate(to: .customerContent)
//                                path.append(RoutePath(.customerContent))
//                                Router.shared.changeRoute(RoutePath(.customerContent))
                            }
                        }
                        .navigationDestination(isPresented: $showVendorTypeView, destination: {
                            VendorTypeView()
                        })
                        .navigationDestination(isPresented: $showCustomerContent, destination: {
                            CustomerContentView()
                        })
                        .disabled(!isVendorPressed && !isCustomerPressed)
//                        .task {
//                            Router.shared.changeRoute = changeRoute
//                            Router.shared.backRoute = backRoute
//                        }
                    }
                }
            }
//            .navigationDestination(for: RoutePath.self) { route in
//                switch route.route {
//                   
//                case .welcome:
//                    WelcomeView()
//
//                case .customerContent:
//                    CustomerContentView()
////                    NavigationStack(path: [RoutePath(.customerContent)]) {
////                                            // Your actual ContentView content here
////                                        }
//                case .vendorType:
//                    VendorTypeView()
//                    
//                case .businessDetailsView:
//                    Text("businessDetailsView")
//                    
//                case .userRole:
//                    Text("userRole")
//                case .contentView:
//                    Text("contentView")
//                    
//                case .none:
//                    Text("none")
//                    
//                }
//            }
        }
    }
    
    func resetButtons(isVendor: Bool = false, isCustomer: Bool = false) {
        isVendorPressed = isVendor
        isCustomerPressed = isCustomer
    }
    
//    // MARK: Route
//    func changeRoute(_ route: RoutePath) {
//        path.append(route)
//    }
//    
//    func backRoute() {
//        path.removeLast()
//    }
}

struct UserRoleView_Previews: PreviewProvider {
    static var previews: some View {
        UserRoleView()
    }
}
