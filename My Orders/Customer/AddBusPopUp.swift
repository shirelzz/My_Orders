//
//  AddBusPopUp.swift
//  Confetti
//
//  Created by שיראל זכריה on 10/02/2024.
//

import SwiftUI

enum DecryptionError: Error {
    case invalidBase64
    case invalidData
    case authenticationFailure
    case decryptionFailure
}

enum EncryptionError: Error {
    case invalidKey
    case invalidData
}

struct AddBusPopUp: View {
    
    @ObservedObject var customerManager: CustomerManager
    
    @State private var encCode = ""
    @State private var decCode = ""
    @State private var validCode = false
    @State private var vendorItems: [InventoryItem] = []
    @State private var errorMessage = ""
    
    @Binding var isActive: Bool
    let title: String
    let buttonTitle: String
    @State private var offset: CGFloat = 1000
    
    var body: some View {
        
        ZStack {
            
            Color(.black)
                .opacity(0.4)
            
            VStack()  {
                
                Text(title)
                    .font(.headline)
                    .bold()
                    .foregroundStyle(.gray)
                    .padding()
                
                TextField("Enter code", text: $encCode)
                    .frame(minHeight: 100)
                    .onChange(of: encCode) { _ in
                        if !encCode.isEmpty {
                            decryptCode()
                        }
                        else {
                            resetState()
                        }
                    }
                    .foregroundStyle(Color.black.opacity(0.8))
                    .labelStyle(.titleOnly)
                    .padding()
                
                Button {
                    action()
                    close()
                } label: {
                    
                    Text(buttonTitle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .frame(height: 50)
                .padding()
                .disabled(!validCode)

            }
            //.padding()
            .background(.white)
            .offset(x: 0, y: offset)
            .shadow(radius: 20)
//            .frame(maxHeight: 450)
            //.padding(20) //30
            .clipShape(RoundedRectangle(cornerRadius: 20)) //RoundedRectangle(cornerRadius: 20) , , style: .continuous
            .overlay(alignment: .topTrailing) {
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                .tint(.black.opacity(0.8))
                .padding()
            }
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
            .padding()

        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)  // For full-screen coverage
    }
    
    func action() {
        if validCode {
            print("valid code")
            customerManager.fetchBusinessDiaplayName(vandorID: decCode) { name in
                print("name: \(name)")
                let bus = Business(id: decCode, name: name)
                print("created bus")
                customerManager.saveBusiness2Db(bus)
                print("saved bus")
            }
        }
    }
    
    func close() {
        withAnimation(.spring()) {
            offset = 1000
            isActive = false
            
        }
    }
    
    private func resetState() {
        decCode = ""
        validCode = false
        errorMessage = ""
    }
    
    private func decryptCode() {
        do {
            let sanitizedEncCode = sanitizePath(encCode)
            let decryptedID = try AESCryptor.decrypt(sanitizedEncCode)
            decCode = decryptedID
//            let bus = Business(id: decCode, name: "")
            validCode = true
            errorMessage = ""
            print("decryptedID: \(decryptedID)")
        } catch DecryptionError.invalidBase64 {
            validCode = false
            errorMessage = "Invalid base64 encoding"
        } catch DecryptionError.invalidData {
            validCode = false
            errorMessage = "Invalid data"
        } catch {
            validCode = false
            errorMessage = "Unknown error"
        }
    }
    
    private func sanitizePath(_ path: String) -> String {
        return path.replacingOccurrences(of: "[\\.\\#\\$\\[\\]]", with: "", options: .regularExpression)
    }

    
}
