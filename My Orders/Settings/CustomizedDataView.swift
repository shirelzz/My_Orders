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
    
//    let logoImage = AppManager.shared.logoImg
//    let signatureImage = AppManager.shared.signatureImg

    
    var body: some View {
        
        Form{
            List{
                Section(header: Text("Logo")) {
                                    
                    HStack{
                                        
                        if let logoImageData = appManager.manager.logoImgData,
                           let logoImage = UIImage(data: logoImageData) {
                            Image(uiImage: logoImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        } else {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        
                        Spacer()
                        
                        Button{
                            showLogoImgPicker = true
                            
                        } label: {
                            Text("Select image")
                        }
                        .sheet(isPresented: $showLogoImgPicker) {
                            ImagePicker(selectedImage: $logoImage, isPickerShowing: $showLogoImgPicker)
                        }
                    }
                }
                                
                Section(header: Text("Signature")) {
                    HStack {
                                                
                        if let signatureImageData = appManager.manager.signatureImgData,
                           let signatureImage = UIImage(data: signatureImageData) {
                            Image(uiImage: signatureImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                        } else {
                            
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .frame(width: 50, height: 50)
                            //                                       Text("Error loading signature image")
                        }
                        
                        Spacer()
                        
                        Button{
                            showSignatureImgPicker = true
                        } label: {
                            Text("Select image")
                        }
                        .sheet(isPresented: $showSignatureImgPicker, content: {
                            ImagePicker(selectedImage: $signatureImage, isPickerShowing: $showSignatureImgPicker)
                        })
                    }
                }
                                
                HStack {
                                        
                    Button("Save images"){
                        
                        if let logoImageData = logoImage?.pngData(),
                           let signatureImageData = signatureImage?.pngData() {
                            
                            let manager = Manager(
                                
                                logoImgData: logoImageData,
                                signatureImgData: signatureImageData
                            )
                            AppManager.shared.saveManager(manager: manager)
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
