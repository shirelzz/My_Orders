//
//  CustomizedDataView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

extension UIImage {
    convenience init?(data: Data) {
        self.init(data: data, scale: UIScreen.main.scale)
    }
}

struct CustomizedDataView: View {
    
    @ObservedObject var appManager: AppManager
//    @ObservedObject var vendorManager: VendorManager

    @State private var logoImage: UIImage?
    @State private var signatureImage: UIImage?
    
    @State private var showLogoImgPicker = false
    @State private var showSignatureImgPicker = false
    
    @State private var businessName = VendorManager.shared.vendor.businessName
    @State private var businessID = VendorManager.shared.vendor.businessID
    @State private var businessAddress = VendorManager.shared.vendor.businessAddress
    @State private var businessPhone = VendorManager.shared.vendor.businessPhone
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Form {
            List {
                
                Section() {
                    HStack {
                        appManager.getLogoImage()
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                        Spacer()
                        Button {
                            showLogoImgPicker = true
                        } label: {
                            Text("Select image")
                        }
                        .sheet(isPresented: $showLogoImgPicker) {
                            ImagePicker(selectedImage: $logoImage, isPickerShowing: $showLogoImgPicker)
                                .onDisappear {
                                    // This block will be executed when the ImagePicker is dismissed
                                    appManager.manager.logoImgData = logoImage?.pngData()
                                }
                        }
                    }
                } header: {
                    Text("Logo")
                } footer: {
                    Text("This Photo will be used for your receipts as a logo")
                }
                

                Section() {
                    VStack(alignment: .leading, spacing: 8) {

                    HStack {
                        appManager.getSignatureImage()
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                        Spacer()
                        Button {
                            showSignatureImgPicker = true
                        } label: {
                            Text("Select image")
                        }
                        .sheet(isPresented: $showSignatureImgPicker) {
                            ImagePicker(selectedImage: $signatureImage, isPickerShowing: $showSignatureImgPicker)
                                .onDisappear {
                                    // This block will be executed when the ImagePicker is dismissed
                                    appManager.manager.signatureImgData = signatureImage?.pngData()
                                }
                        }
                    }
                    
                        
                    }
                } header: {
                    Text("Signature")
                } footer: {
                    Text("This Photo will be used for your receipts as a signature")
                }
                
                Section() {
                    List {
//                    VStack(alignment: .leading, spacing: 8) {
                        
                        
                            TextField("Name" , text: $businessName)
                                .autocorrectionDisabled()

                            TextField("Identifier" , text: $businessID)
                                .keyboardType(.numberPad)

                            TextField("Address" , text: $businessAddress)
                                .autocorrectionDisabled()

                            TextField("Phone number" , text: $businessPhone)
                                .keyboardType(.numberPad)
//                        }

                        
                    }
                } header: {
                    Text("Business Details")
                } footer: {
                    Text("These details will be used for your receipts")
                }
                
                HStack {
                    
                    Button("Save") {
                        if appManager.manager.logoImgData == nil && appManager.manager.signatureImgData == nil {
                            // First time uploading images
                            appManager.saveManager(manager: Manager(
                                logoImgData: logoImage?.pngData(),
                                signatureImgData: signatureImage?.pngData()
                            ))
                        } else {
                            // Replace existing images
                            appManager.updateManager(
                                logoImageData: logoImage?.pngData(),
                                signatureImageData: signatureImage?.pngData()
                            )
                        }
                        
                        VendorManager.shared.updateVendor(businessID: businessID, businessName: businessName, businessAddress: businessAddress, businessPhone: businessPhone)
                                                
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CustomizedDataView(appManager: AppManager.shared)
}
