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
            
//            Text("Start creatng receipts at")
//            TextField("Receipt number", text: Binding<String>(
//                get: { String(receiptNumber) },
//                set: { if let newValue = Int($0) {
//                    receiptNumber = newValue
//                    
//                    //send receiptNumber to the order manager
//                    OrderManager.shared.setStartingReceiptNumber(newValue)} }
//            ))
//            .keyboardType(.numberPad)
            
            Section(header: Text("Start creatng receipts at")) {
                
                Text("Current receipt Number \(OrderManager.shared.getLastReceiptID() + 1)")
                
                TextField("Receipt number", text: $receiptNumberString)
                .keyboardType(.numberPad)
                .onSubmit {
                    validateReceiptNum()
                }
                
                Button("Save") {
                    if validReceiptNum {
                        OrderManager.shared.setStartingReceiptNumber(receiptNumber)
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }

            }
        }
    }
    
    private func validateReceiptNum() {
        validReceiptNum = Int(receiptNumberString) ?? 1 >= 1
        if validReceiptNum {
            receiptNumber = Int(receiptNumberString) ?? 1
        }
    }
}
