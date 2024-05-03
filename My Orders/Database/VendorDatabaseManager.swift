//
//  VendorDatabaseManager.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/04/2024.
//

import Foundation

class VendorDatabaseManager: DatabaseManager {
    
    static var shared = VendorDatabaseManager()
    
    // MARK: - Reading data
    
    func fetchVendor(path: String, completion: @escaping (Vendor?) -> ()) {
          
        let vendorRef = databaseRef.child(path)
        
        vendorRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? [String: Any] else {
                print("No vendor data found")
                completion(nil)
                return
            }

            var vendor: Vendor?
                guard let vendorDict = snapshot.value as? [String: Any],
                      let uid = vendorDict["uid"] as? String,
                      let businessID = vendorDict["businessID"] as? String,
                      let businessName = vendorDict["businessName"] as? String,
                      let businessAddress = vendorDict["businessAddress"] as? String,
                      let businessPhone = vendorDict["businessPhone"] as? String,
                    let businessDiaplayName = vendorDict["businessDiaplayName"] as? String
                else {
                    print("Error parsing vendor data")
                    return
                }
                        
            vendor = Vendor(
                uid: uid,
                businessID: businessID,
                businessName: businessName,
                businessAddress: businessAddress,
                businessPhone: businessPhone,
                businessDiaplayName: businessDiaplayName
            )
            
            completion(vendor)
        })
    }
    
    func fetchVendorName(path: String, completion: @escaping (String) -> Void) {
        let vendorsRef = databaseRef.child(path)
        vendorsRef.observeSingleEvent(of: .value) { snapshot in
            if let name = snapshot.value as? String {
                completion(name)
            } else {
                completion("")
            }
        }
    }
    
    func fetchWorkingHours(path: String, completion: @escaping ([WorkingDay]) -> ()) {
      
        let vendorsRef = databaseRef.child(path)
        
        vendorsRef.observeSingleEvent(of: .value, with: { (snapshot) in
        guard let value = snapshot.value as? [String: Any] else {
                print("No WorkingDay data found")
                completion([])
                return
            }
            
            var workingDays = [WorkingDay]()
            for (_, itemData) in value {
                guard let workingDayDict = itemData as? [String: Any],
                      let id = workingDayDict["id"] as? String,
                      let day = workingDayDict["day"] as? String,
                      let fromStr = workingDayDict["from"] as? String,
                      let toStr = workingDayDict["to"] as? String

                else {
                    print("WorkingDay else called")
                    continue
                }
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"

                if let fromDate = dateFormatter.date(from: fromStr ),
                   let toDate = dateFormatter.date(from: toStr ) {
                    let wd = WorkingDay(id: id, day: day, from: fromDate, to: toDate)
                    
                    workingDays.append(wd)
                }
                
            }
            completion(workingDays)
        })
    }
    
    // MARK: - Writing data
    
    func saveVendor(_ vendor: Vendor, path: String) {
        let vendorRef = databaseRef.child(path) //.child(user.id)
        vendorRef.setValue(vendor.dictionaryRepresentation()) { error, _ in
            if let error = error {
                print("Error saving vendor: \(error.localizedDescription)")
            } else {
                print("saved vendor")
            }
        }
    }
    
    func saveVendorDisplayedName(_ name: String, path: String) {
        let vendorsRef = databaseRef.child(path) //.child(user.id)
        vendorsRef.setValue(name) { error, _ in
            if let error = error {
                print("Error saving vendor name: \(error.localizedDescription)")
            } else {
                print("saved vendor")
            }
        }
    }
    
    func saveBusinessHours(_ businessHours: [WorkingDay], path: String) {
        let vendorsRef = databaseRef.child(path) //.child(user.id)
        // Convert the array of WorkingDay objects into a dictionary
        let workingHoursDict = businessHours.map { $0.dictionaryRepresentation() }
        
        vendorsRef.setValue(workingHoursDict) { error, _ in
            if let error = error {
                print("Error saving vendor businessHours: \(error.localizedDescription)")
            } else {
                print("saved vendor businessHours")
            }
        }
    }
    
    // MARK: - Updating data
    
    func updateVendorInDB(_ vendor: Vendor, path: String, completion: @escaping (Bool) -> Void) {
        let vendorRef = databaseRef.child(path) //child(vendor.uid) ?
        vendorRef.updateChildValues(vendor.dictionaryRepresentation()) { error, _ in
            completion(error == nil)
        }
    }
}
