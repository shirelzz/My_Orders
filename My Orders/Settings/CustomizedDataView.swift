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

    @State private var logoImage: UIImage?
    @State private var signatureImage: UIImage?
    
    @State private var showLogoImgPicker = false
    @State private var showSignatureImgPicker = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        Form {
            List {
                
                Section(header: Text("Logo")) {
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
                }

                Section(header: Text("Signature")) {
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

                                
                HStack {
                    
                    Button("Save images") {
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
