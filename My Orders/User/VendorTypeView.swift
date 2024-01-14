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
    @State private var showBackView = false
    @State private var isFoodPressed = false
    @State private var isBeautyPressed = false
    @State private var isOtherPressed = false
    @State private var user: User = User()
    @State private var path: NavigationPath = NavigationPath()
    
    var body: some View {
        
//        let width = UIScreen.main.bounds.width - 32
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
                                user = User(uid: UUID().uuidString, role: .vendor, vendorType: .food)
                                resetButtons(isFood: true)
                    
                    //                    UserManager.shared.saveUser(user: user)
                    //                    hasLaunchedBefore = true
                                        showContentView = true
                })
//                .navigationDestination(isPresented: $showContentView) {
//                    ContentView()
//                }
                
                CustomButton(title: "Beauty", isPressed: $isBeautyPressed, action: {
                    user = User(uid: UUID().uuidString, role: .vendor, vendorType: .beauty)
                    resetButtons(isBeauty: true)
                    
                    //                    UserManager.shared.saveUser(user: user)
                    //                    hasLaunchedBefore = true
                    //                    showContentView = true
                })
                
                Text("or")
                    .foregroundColor(.gray)
                    .padding()
                
                CustomButton(title: "Other", isPressed: $isOtherPressed, action: {
                    user = User(uid: UUID().uuidString, role: .vendor, vendorType: .other)
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
                            Router.shared.changeRoute(RoutePath(.userRole))
//                            Router.shared.backRoute()
//                            showBackView = true
                        }
                        
//                        .navigationDestination(isPresented: $showBackView, destination: {
//                            UserRoleView()
//                        })
                        
                        Spacer()
                        
                        Button("Done") {
                            UserManager.shared.saveUser2DB(user)
                            hasLaunchedBefore = true
                            showContentView = true
                            Router.shared.changeRoute(RoutePath(.contentView))
                        }
//                        .navigationDestination(isPresented: $showContentView, destination: {
//                            ContentView()
//                        })
                        .disabled(!isFoodPressed && !isBeautyPressed && !isOtherPressed)
                        .task {
                            Router.shared.changeRoute = changeRoute
                            Router.shared.backRoute = backRoute
                        }
                    }
                }
            }
            .navigationDestination(for: RoutePath.self) { route in
                switch route.route {
                case .customerContent:
                    Text("customerContent")
                    
                case .vendorType:
                    Text("vendorType")
                    
                case .userRole:
    //                Router.shared.backRoute()
                    UserRoleView()
    //                Text("")

                case .contentView:
                    ContentView()

                case .none:
                    EmptyView()
//                    Text("none")

                }
            }
        }
        

    }
    
    func resetButtons(isFood: Bool = false, isBeauty: Bool = false, isOther: Bool = false) {
        isFoodPressed = isFood
        isBeautyPressed = isBeauty
        isOtherPressed = isOther
    }
    
    // MARK: Route
        func changeRoute(_ route: RoutePath) {
            path.append(route)
        }

        func backRoute() {
            path.removeLast()
        }
}

#Preview {
    VendorTypeView()
}
