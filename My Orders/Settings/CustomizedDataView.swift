//
//  CustomizedDataView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

struct CustomizedDataView: View {
    
    @State private var logoImage: UIImage?
    @State private var signatureImage: UIImage?
    
    @State private var showLogoImgPicker = false
    @State private var showSignatureImgPicker = false
    
    @StateObject private var appManager = AppManager.shared
//    let logoImage = AppManager.shared.logoImg
//    let signatureImage = AppManager.shared.signatureImg

    
    var body: some View {
        
//        VStack{
            
            
//            Section(header: Text("Logo")) {
                
        VStack (alignment: .leading) {
                    
                    Spacer()
                    
                    HStack{
                        
                        Spacer()
                        


                        if (logoImage != nil){
                            
                            Image(uiImage: logoImage!)
                                .resizable()
                                .frame(width: 100, height: 100)
                        } 
                        
//                        if let logoImage = logoImage {
//                            Image(uiImage: logoImage)
//                                .resizable()
//                                .frame(width: 100, height: 100)
//                        }
                        
                        else {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        
                        Spacer()
                        
                        Button{
                            showLogoImgPicker = true

                        } label: {
                            Text("Select logo image")
                        }
                        .sheet(isPresented: $showLogoImgPicker) {
                            ImagePicker(selectedImage: $logoImage, isPickerShowing: $showLogoImgPicker)
                        }
                        
                        Spacer()

                    }
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                if (signatureImage != nil){
                    Image(uiImage: signatureImage!)
                        .resizable()
                        .frame(width: 100, height: 100)
                } else {
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .frame(width: 50, height: 50)
                        
                }
                
                Spacer()
                
                Button{
                    showSignatureImgPicker = true
                } label: {
                    Text("Select signature image")
                }
                .sheet(isPresented: $showSignatureImgPicker, content: {
                    ImagePicker(selectedImage: $signatureImage, isPickerShowing: $showSignatureImgPicker)
                })
                
                Spacer()
               
            }
            
            Spacer()
            
            HStack {
                
                Spacer()
                
                Button("Save images"){
                    
                    if let logoImageData = logoImage?.pngData(),
                        let signatureImageData = signatureImage?.pngData() {
                        
                        let manager = Manager(
                            
                            logoImgData: logoImageData,
                            signatureImgData: signatureImageData
                        )
                        AppManager.shared.saveManager(manager: manager)
                    }
                }
                
                Spacer()

            }

            
            
            
            Spacer()
        }
        
    }
}

#Preview {
    CustomizedDataView()
}
