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
                        } else {
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
                        .sheet(isPresented: $showLogoImgPicker, content: {
                            ImagePicker(selectedImage: $logoImage, isPickerShowing: $showLogoImgPicker)
                        })
                        
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
        }
        
    }
}

#Preview {
    CustomizedDataView()
}
