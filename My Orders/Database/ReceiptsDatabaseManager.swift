//
//  ReceiptsDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation

class ReceiptsDatabaseManager: DatabaseManager {
    
    static var shared = ReceiptsDatabaseManager()
    
    // MARK: - Reading data

    func fetchReceipts(path: String, completion: @escaping ([Receipt]) -> ()) { // Set<Receipt>
        let receiptsRef = databaseRef.child(path)
        
        receiptsRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                print("No receipts data found")
                completion([])
                return
            }
            
            var receipts = [Receipt]()
            for (_, receiptData) in value {
                guard let receiptDict = receiptData as? [String: Any],
                      let id = receiptDict["id"] as? String,
                      let myID = receiptDict["myID"] as? Int,
                      let orderID = receiptDict["orderID"] as? String,
                      let dateGeneratedStr = receiptDict["dateGenerated"] as? String,
                      let paymentMethod = receiptDict["paymentMethod"] as? String,
                      let paymentDetails = receiptDict["paymentDetails"] as? String,
                      let paymentDateStr = receiptDict["paymentDate"] as? String
                        
                else {
                    print("receipt else called")
                    continue
                }
                
//                let paymentDetails = receiptDict["paymentDetails"] as? String ?? ""

                let dateGenerate = self.convertStringToDate(dateGeneratedStr)
                let paymentDate =  self.convertStringToDate(paymentDateStr)
                
                let discountAmount = receiptDict["discountAmount"] as? Double
                let discountPercentage = receiptDict["discountPercentage"] as? Double
                
                let receipt = Receipt(
                    id: id,
                    myID: myID,
                    orderID: orderID,
                    dateGenerated: dateGenerate,
                    paymentMethod: paymentMethod,
                    paymentDetails: paymentDetails,
                    paymentDate: paymentDate,
                    discountAmount: discountAmount,
                    discountPercentage: discountPercentage
                )
                
                receipts.append(receipt)
            }
            
            completion(receipts) // Set(receipts)
        })
    }
    
    func fetchReceiptValues(path: String, completion: @escaping (ReceiptValues) -> ()) {
        let receiptValuesRef = databaseRef.child(path)

        receiptValuesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any],
            let receiptNumber = value["receiptNumber"] as? Int,
            let receiptNumberReset = value["receiptNumberReset"] as? Int
            
            
            else {
                print("No receipt values found")
                completion(ReceiptValues(receiptNumber: -1, receiptNumberReset: -1))
                return
            }
            
            let recValues = ReceiptValues(receiptNumber: receiptNumber, receiptNumberReset: receiptNumberReset)

            completion(recValues)
        })
    }
    
    func migrateReceiptsToAddPaymentDetails(path: String, defaultPaymentDetails: String = "") {
        let receiptsRef = databaseRef.child(path)
        
        receiptsRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("No receipts data found")
                return
            }
            
            for (receiptID, receiptData) in value {
                if var receiptDict = receiptData as? [String: Any] {
                    
                    // Check if `paymentDetails` is missing
                    if receiptDict["paymentDetails"] == nil {
                        var updatedPaymentDetails = defaultPaymentDetails
                        
                        // Check if paymentMethod is "Paybox" or "Bit"
                        if let paymentMethod = receiptDict["paymentMethod"] as? String,
                           paymentMethod == "Paybox" || paymentMethod == "Bit" {
                            
                            // Set paymentDetails to the payment method (e.g., "Paybox" or "Bit")
                            updatedPaymentDetails = "Supplier: \(paymentMethod) /"
                            
                            // Change paymentMethod to "Payment App"
                            receiptDict["paymentMethod"] = "Payment App"
                        }
                        
                        // Update paymentDetails with either the method or the default value
                        receiptDict["paymentDetails"] = updatedPaymentDetails
                        
                        // Update the receipt in the database
                        receiptsRef.child(receiptID).setValue(receiptDict) { error, _ in
                            if let error = error {
                                print("Failed to update receipt \(receiptID): \(error)")
                            } else {
                                print("Successfully updated receipt \(receiptID) with payment details")
                            }
                        }
                    }
                }
            }
            
        })
    }


    
    // MARK: - Writing data

    func saveReceipt(_ receipt: Receipt, path: String) {
        let receiptRef = databaseRef.child(path).child(receipt.orderID)
        receiptRef.setValue(receipt.dictionaryRepresentation())
    }
    
    func saveOrUpdateReceiptValuesInDB(_ values: ReceiptValues, path: String, completion: @escaping (Bool) -> Void) {

        let receiptValuesRef = databaseRef.child(path)

        receiptValuesRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // Data exists, update it
                receiptValuesRef.updateChildValues(values.dictionaryRepresentation()) { error, _ in
                    completion(error == nil)
                }
            } else {
                // Data doesn't exist, set the new data
                receiptValuesRef.setValue(values.dictionaryRepresentation()) { error, _ in
                    completion(error == nil)
                }
            }
        }
    }
    
    // MARK: - Deleting data
    
    func deleteReceipt(orderID: String, path: String) {
        let receiptRef = databaseRef.child(path).child(orderID)
        receiptRef.removeValue()
    }
}
