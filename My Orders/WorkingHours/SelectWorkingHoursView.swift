//
//  SelectWorkingHoursView.swift
//  Confetti
//
//  Created by שיראל זכריה on 12/02/2024.
//

import SwiftUI

struct SelectWorkingHoursView: View {

let daysOfWeek = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

@State private var selectedDay: String = "Sunday"
@State private var chooseHours = false
    
    var workingHours: [WorkingDay] {
       return VendorManager.shared.getWorkingHoursFromDB()
    }

    var body: some View {
        
        VStack {
            
            List(daysOfWeek, id: \.self) { day in
                Button(action: {
                    selectedDay = day
                    chooseHours = true
                }) {
                    VStack{
                        Text(day.localized)
                            .foregroundStyle(HelperFunctions.isDarkMode() ? .white : .black)
                        
                    }
                }
                .sheet(isPresented: $chooseHours, content: {
                    WorkingHoursDetailView(day: selectedDay)
                })
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Select Working Hours")
    }
    
    func getDayHours(day: String) -> WorkingDay? {
        return workingHours.first(where: { $0.day == day })
    }



    
}

#Preview {
    SelectWorkingHoursView()
}
