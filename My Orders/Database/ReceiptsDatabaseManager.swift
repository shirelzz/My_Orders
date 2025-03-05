//
//  ReceiptsDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation
import FirebaseAuth

class ReceiptsDatabaseManager: DatabaseManager {
    
    static var shared = ReceiptsDatabaseManager()
    let userID = Auth.auth().currentUser?.uid ?? ""

    
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
                      let paymentInfoDict = receiptDict["paymentInfo"] as? [String: Any]

                else {
                    print("receipt else called")
                    continue
                }
                
                // Define a default invalid date for failed conversions
                let invalidDate = Date(timeIntervalSince1970: 0) // 1970-01-01 (Unix epoch)

                var dateGenerate: Date = invalidDate
                var paymentDate: Date = invalidDate
                do {
                    dateGenerate = try self.convertStringToDate(dateGeneratedStr)
                    paymentDate = try self.convertStringToDate(paymentInfoDict["date"] as? String ?? "")
                    print("Dates converted successfully:", dateGenerate, paymentDate)
                } catch DateConversionError.emptyString {
                    print("Error: Empty date string")
                } catch DateConversionError.invalidFormat {
                    print("Error: Invalid date format")
                } catch {
                    print("Unknown error:", error)
                }

                let paymentInfo = PaymentInfoModel(
                    method: PaymentMethod(rawValue: paymentInfoDict["method"] as? String ?? "") ?? .cash,
                    details: paymentInfoDict["details"] as? String ?? "",
                    date: paymentDate,
                    paymentApp: paymentInfoDict["paymentApp"] as? String ?? ""
                )

                
                let discountAmount = receiptDict["discountAmount"] as? Double
                let discountPercentage = receiptDict["discountPercentage"] as? Double
                
                let receipt = Receipt(
                    id: id,
                    myID: myID,
                    orderID: orderID,
                    dateGenerated: dateGenerate,
                    paymentInfo: paymentInfo,
                    discountAmount: discountAmount,
                    discountPercentage: discountPercentage
                )
                
                receipts.append(receipt)
            }
            
            completion(receipts)
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
    
//    func migrateReceiptsToNewPaymentInfoModel() {
//        fetchAllReceiptsForMigration { receipts in
//            for var receipt in receipts {
//                
//                // Convert old payment fields into the new PaymentInfoModel
//                let fetchedPaymentMethod = receipt.paymentMethod ?? "cash"
//                let formattedPaymentMethod = PaymentMethod(rawValue: fetchedPaymentMethod)
//                let paymentInfo = PaymentInfoModel(
//                    method: formattedPaymentMethod ?? PaymentMethod.cash,
//                    details: receipt.paymentDetails ?? "",
//                    date: receipt.paymentDate ?? Date(), // Convert String to Date
//                    paymentApp: receipt.paymentMethod == "Payment App" ? receipt.paymentDetails?.components(separatedBy: " /").first ?? "" : ""
//                )
//
//                // Update the receipt with the new model
//                receipt.paymentInfo = paymentInfo
//
////                // Remove old fields (optional)
////                receipt.paymentMethod = ""
////                receipt.paymentDetails = ""
////                receipt.paymentDate = Date()
//
//                // Save updated receipt back to the database
//                let year = Calendar.current.component(.year, from: receipt.paymentInfo.date)
//                let newPath = "users/\(self.userID)/receipts/\(year)/\(receipt.orderID)"
//
//                ReceiptsDatabaseManager.shared.saveReceipt(receipt, path: newPath)
//            }
//            
//            print("✅ Migration complete! Receipts now use PaymentInfoModel.")
//        }
//    }
    
//    func migrateReceiptsToNewPaymentInfoModel() {
//        let oldPath = "users/\(userID)/receipts"
//
//        fetchAllReceiptsForMigration { receipts in
//            print("🔄 Fetching receipts for migration... Found \(receipts.count) receipts")
//
//            for var receipt in receipts {
//                print("🔄 Processing receipt \(receipt.orderID)...")
//
//                let fetchedPaymentMethod = receipt.paymentMethod ?? "cash"
//                let formattedPaymentMethod = PaymentMethod(rawValue: fetchedPaymentMethod)
//
//                let paymentInfo = PaymentInfoModel(
//                    method: formattedPaymentMethod ?? .cash,
//                    details: formattedPaymentMethod == PaymentMethod.paymentApp ? "" :
//                    receipt.paymentDetails ?? "",
//                    date: receipt.paymentDate ?? Date(),
//                    paymentApp: receipt.paymentMethod == "Payment App" ? receipt.paymentDetails?.components(separatedBy: " /").first ?? "" : ""
//                )
//
//                // ✅ Update receipt with new PaymentInfoModel
//                receipt.paymentInfo = paymentInfo
//
//                // Save updated receipt
//                let year = Calendar.current.component(.year, from: receipt.dateGenerated)
//                let newPath = "users/\(self.userID)/receipts/\(year)"
//
//                print("📤 Saving updated receipt \(receipt.orderID) to \(newPath)")
//                
//                ReceiptsDatabaseManager.shared.saveReceipt(receipt, path: newPath)
//                
//                
//                ReceiptsDatabaseManager.shared.deleteReceipt(orderID: receipt.orderID, path: oldPath)
//                print("🗑 Deleting old receipt at \(oldPath)")
//
//
//            }
//
//            print("✅ Migration complete! All receipts updated.")
//        }
//    }


    
//    func migrateReceiptsToYearBasedStorage() {
//        fetchAllReceiptsForMigration { receipts in
//            for receipt in receipts {
//                let year = Calendar.current.component(.year, from: receipt.paymentInfo.date)
//                let newPath = "users/\(self.userID)/receipts/\(year)/\(receipt.orderID)"
//                
//                // Save receipt to the new path
//                ReceiptsDatabaseManager.shared.saveReceipt(receipt, path: newPath)
//                
//                // Delete from old path
//                let oldPath = "users/\(self.userID)/receipts/\(receipt.orderID)"
//                ReceiptsDatabaseManager.shared.deleteReceipt(orderID: receipt.orderID, path: oldPath)
//            }
//            
//            print("✅ Migration complete! Receipts are now stored by year.")
//        }
//    }


    
    
    func migrateReceiptsToAddPaymentDetails(path: String, defaultPaymentDetails: String = "") {
        let receiptsRef = databaseRef.child(path)
        
        receiptsRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("No receipts data found")
                return
            }
            
            for (receiptID, receiptData) in value {
                if var receiptDict = receiptData as? [String: Any] {
                    
                    // Check if `paymentDetails` exists and contains "Supplier: "
                    if let paymentDetails = receiptDict["paymentDetails"] as? String, paymentDetails.contains("Supplier:") {
                        
                        // Remove "Supplier: " prefix if it exists
                        let updatedPaymentDetails = paymentDetails.replacingOccurrences(of: "Supplier: ", with: "")
                        
                        // Update `paymentDetails` in `receiptDict`
                        receiptDict["paymentDetails"] = updatedPaymentDetails
                        
                        // Update the receipt in the database
                        receiptsRef.child(receiptID).setValue(receiptDict) { error, _ in
                            if let error = error {
                                print("Failed to update receipt \(receiptID): \(error)")
                            } else {
                                print("Successfully updated receipt \(receiptID) by removing 'Supplier:' from payment details")
                            }
                        }
                    }
                }
            }
        })
    }

    func fetchAllReceiptsForMigration(completion: @escaping ([Receipt]) -> Void) {
        let path = "users/\(userID)/receipts"
        
        ReceiptsDatabaseManager.shared.fetchReceipts(path: path) { fetchedReceipts in
            DispatchQueue.main.async {
                completion(fetchedReceipts)
            }
        }
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
