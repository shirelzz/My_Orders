//
//  PaymentDetailsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 08/11/2024.
//

import SwiftUI

struct PaymentDetailsView: View {
    @Binding var selectedPaymentMethod: String
    @Binding var selectedPaymentApp: String
    @Binding var selectedPaymentDetails: String
    @Binding var additionalDetails: String
    @Binding var selectedPaymentDate: Date
    
    var body: some View {
        Section(header: Text("Payment Details")) {
            
            // Date Picker for Payment Date
            DatePicker("Payment Date", selection: $selectedPaymentDate, in: ...Date(), displayedComponents: .date)
            
            // Payment Method Picker
            Picker("Payment Method", selection: $selectedPaymentMethod) {
                Text("Payment App").tag("Payment App")
                Text("Bank transfer").tag("Bank transfer")
                Text("Cash").tag("Cash")
                Text("Cheque").tag("Cheque")
            }
            .onChange(of: selectedPaymentMethod) { _ in updatePaymentDetails() } // Update details when method changes
            
            // Conditional Picker for Payment App
            if selectedPaymentMethod == "Payment App" {
                Picker("Select Payment App", selection: $selectedPaymentApp) {
                    Text("Paybox").tag("Paybox")
                    Text("Bit").tag("Bit")
                    Text("Other").tag("Other")
                }
                .onChange(of: selectedPaymentApp) { _ in updatePaymentDetails() } // Update details when app changes
            }
            
            // Text Field for Additional Payment Details
            TextField("Additional Payment Details", text: $additionalDetails)
                .onChange(of: additionalDetails) { _ in updatePaymentDetails() } // Update details when text changes
        }
    }
    
    // Helper function to update `selectedPaymentDetails`
    private func updatePaymentDetails() {
        if selectedPaymentMethod == "Payment App" {
            selectedPaymentDetails = "\(selectedPaymentApp). \(additionalDetails)"
        } else {
            selectedPaymentDetails = additionalDetails
        }
    }
}


//#Preview {
//    PaymentDetailsView(selectedPaymentMethod: <#Binding<String>#>, selectedPaymentApp: <#Binding<String>#>, selectedPaymentDetails: <#Binding<String>#>, additionalDetails: <#Binding<String>#>, selectedPaymentDate: <#Binding<Date>#>)
//}
