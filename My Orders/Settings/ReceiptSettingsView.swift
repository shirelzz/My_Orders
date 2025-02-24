//
//  ReceiptSettingsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 29/11/2023.
//

import SwiftUI

struct ReceiptSettingsView: View {
    
    @ObservedObject var appManager: AppManager
    @ObservedObject var orderManager: OrderManager
    @State private var receiptNumberString = ""
    @State private var receiptNumber = 1
    @State private var validReceiptNum = false
    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        Form{
            
            Section(header: Text("Start creatng receipts at")) {
                
                Text("Current receipt Number \(orderManager.getLastReceiptID() + 1)")
                
                TextField("Receipt number", text: $receiptNumberString)
                .keyboardType(.numberPad)
                .onChange(of: receiptNumberString, perform: { _ in
                    validateReceiptNum()
                })
                
                Button("Save") {
                    if validReceiptNum {
                        print("saving")
                        receiptNumber = Int(receiptNumberString) ?? 1
                        
                        orderManager.setStartingReceiptNumber(receiptNumber)
                        
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }

            }
        }
    }
    
    private func validateReceiptNum() {
        validReceiptNum = Int(receiptNumberString) ?? 1 >= 1
    }
}
