//
//  BussinessDetailsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 23/01/2024.
//

import SwiftUI

struct BusinessDetailsView: View {
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore: Bool = false
    @State private var showContentView = false
    @State private var showBackView = false
    @State private var businessName = ""
    @State private var businessID = ""
    @State private var businessAddress = ""
    @State private var businessPhone = ""

    var body: some View {
        
        let height = HelperFunctions.getHeight()

        
        NavigationStack() {
            
            VStack {
                
                Image("aesthetic")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: height/4)
                    .padding(.bottom, 50)
                                
                Text("Business Details")
                    .font(.system(size: 24))
                    .foregroundColor(.black.opacity(0.7))
                    .bold()
                    .padding(.bottom, 40)
                
                Section() {
                    VStack(alignment: .leading, spacing: 10) {
                        
                        TextField("Name" , text: $businessName)
                            .disableAutocorrection(true)
                        
                        TextField("Identifier" , text: $businessID)
                            .keyboardType(.numberPad)

                        TextField("Address" , text: $businessAddress)
                            .disableAutocorrection(true)

                        TextField("Phone number" , text: $businessPhone)
                            .keyboardType(.numberPad)

                    }
                    .textFieldStyle(AccentBorder())
                    .padding()

                } header: {
                    Text("These details will be used for your receipts.\n You can edit them later in settings.")
                        .foregroundColor(.gray)

                } footer: {
                    Text("")
                }
                
                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("Back") {
                            showBackView = true
                        }
                        .navigationDestination(isPresented: $showBackView, destination: {
//                            VendorTypeView()
                            UserRoleView()
                        })
                        
                        Spacer()
                        
                        Button("Done") {
                            VendorManager.shared.updateVendor(businessID: businessID, businessName: businessName, businessAddress: businessAddress, businessPhone: businessPhone)
                            
                            hasLaunchedBefore = true
                            showContentView = true
                        }
                        .navigationDestination(isPresented: $showContentView, destination: {
                            ContentView()
                        })
                    }
                }
            }
        }
        .navigationBarHidden(true)

    }
}

struct AccentBorder: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .frame(height: 15)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color.accentColor.opacity(0.4), lineWidth:2)
            )
    }
}

#Preview {
    BusinessDetailsView()
}
