//
//  CustomerContentView.swift
//  My Orders
//
//  Created by שיראל זכריה on 13/01/2024.
//

import SwiftUI

struct CustomerContentView: View {
    
    @StateObject private var businessManager = BusinessManager.shared
    @State private var isAddBusiness = false
    @State private var showDeleteAlert = false
    @State private var selectedBus: Business = Business()

    var body: some View {
        
        NavigationStack{
            
            ZStack(alignment: .topTrailing) {
                
                //                AppOpenAdView(adUnitID: "ca-app-pub-3940256099942544/5575463023")
                // test:  ca-app-pub-3940256099942544/5575463023
                // mine: ca-app-pub-1213016211458907/7841665686
                
                VStack (alignment: .leading, spacing: 10) {
                    
                    VStack{
                        
                        Image("aesthetic")
                            .resizable()
                            .scaledToFill()
                            .edgesIgnoringSafeArea(.top)
                            .opacity(0.2)
                            .frame(height: 20)
                        
                        HStack {
                            
                            Spacer()
                            
                            Text("Hello")
                                .font(.largeTitle)
                                .bold()
                            
                            Spacer(minLength: 10)
                            
                            Button(action: {
                                withAnimation {
                                    isAddBusiness = true
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 36))
                                    .padding()
                                    .shadow(color: .black.opacity(0.6), radius: 6, x: 0, y: 2)
                                
                            }
                            .sheet(isPresented: $isAddBusiness) {
                                AddBusinessView()
                            }
                            
                        }
                        .padding(.top, 45)
                        
                    }
                    
                    if ListOfBusinesses.isEmpty {

                        Text("No businesses yet")
                            .font(.headline)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        
                    } else {
                        List {
                            ForEach(ListOfBusinesses, id: \.id) { bus in
                                NavigationLink(destination: SeeBusinessDetails() //bus
                                    ){
                                        BusinessRowView(bus: bus)
                                    }
                                    .swipeActions {
                                        
                                        Button("Delete") {
                                            // Handle delete action
                                            selectedBus = bus
                                            print("delete pressed")
                                            showDeleteAlert = true
                                        }
                                        .tint(.red)

                                    }
                            }
                        }
                        .listStyle(.plain)
                        .alert(isPresented: $showDeleteAlert) {
                            Alert(
                                title: Text("Delete Business"),
                                message: Text("Are you sure you want to delete this business?"),
                                primaryButton: .default(Text("Delete")) {
                                    if selectedBus.id != ""{
                                        deleteBus(busID: selectedBus.id)
                                    }
                                },
                                secondaryButton: .cancel(Text("Cancel")) {
                                }
                            )
                        }
                    }
                    
                    Spacer()
                    
                    AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                        .frame(height: 50)
                        .background(Color.white)
                    // test: ca-app-pub-3940256099942544/2934735716
                    // mine: ca-app-pub-1213016211458907/1549825745
                }
            }
        }
        .navigationBarHidden(true)
    }
     
    func deleteBus(busID: String) {
      businessManager.deleteBus(busID: busID)
    }
                                               
    var ListOfBusinesses: [Business] {
        return businessManager.getBusinesses()
    }
}

#Preview {
    CustomerContentView()
}
