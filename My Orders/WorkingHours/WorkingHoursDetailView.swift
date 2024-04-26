//
//  WorkingHoursDetailView.swift
//  Confetti
//
//  Created by שיראל זכריה on 13/02/2024.
//

import SwiftUI

struct WorkingHoursDetailView: View {
    
    let day: String
    
    @State private var workingHours: [WorkingDay] = VendorManager.shared.getWorkingHoursFromDB()
    
    var workingDaySets : [WorkingDay] {
        return workingHours.filter { $0.day == day }
    }

    var body: some View {
        VStack {
            
            VStack {

                ForEach(workingDaySets.indices, id: \.self) { index in
                    
                    VStack {

                        DatePicker("From", selection: Binding<Date>(
                            get: { workingHours[index].from },
                            set: { newValue in
                                workingHours[index].from = newValue
                            }
                        ), displayedComponents: .hourAndMinute)
                        .padding()

                        Divider().background(Color.gray).padding(.horizontal)
                        
                        DatePicker("To", selection: Binding<Date>(
                            get: { workingHours[index].to },
                            set: { newValue in
                                workingHours[index].to = newValue
                            }
                        ), displayedComponents: .hourAndMinute)
                        .padding()
                                                
                        Divider().background(Color.gray).padding(.horizontal)
                        
                        Button(action: {
                            // Delete the set of working hours                            
                            let selectedIndex = workingHours.firstIndex { $0.id == workingDaySets[index].id }
                            if let selectedIndex = selectedIndex {
                                workingHours.remove(at: selectedIndex)
                            }
                        }) {
                            Text("Delete")
                                .foregroundColor(.red)
                                .padding()
                        }
                        .buttonStyle(.borderless)
                    }
                    .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                            )
                    .padding()
                }
                

            }
            .padding()
            
            Button(action: {
                // Add another set of working hours
                workingHours.append(WorkingDay(day: day))
            }) {
                Text("Add Working Hours")
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Spacer()
        }
        .navigationTitle(day)
        //.navigationBarTitleDisplayMode(.inline)
//        .navigationBarItems(trailing: Button("Save") {
//            // Save the working hours to the database
//            saveWorkingHoursToDatabase()
//        })
        .onDisappear(perform: {
            saveWorkingHoursToDatabase()
        })
    }
    
    func saveWorkingHoursToDatabase() {
        VendorManager.shared.saveBusinessHours(businessHours: workingHours)
        print("Saving working hours for \(day): \(workingHours)")
    }
}

//#Preview {
//    WorkingHoursDetailView(day: "Sunday", workingHours: )
//}
