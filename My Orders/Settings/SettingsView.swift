//
//  SettingsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var appManager: AppManager
    @ObservedObject var orderManager: OrderManager
    @State private var darkModeOn = false
    @State private var selectedCurrency = AppManager.shared.currency
    
    var body: some View {
        
        NavigationStack{
            
            List{
                
                Section(header: Text("Personal Information")) {
                    
                    NavigationLink(destination: AccountView()) {
                        Label("Account", systemImage: "person")
                    }
                    
                    NavigationLink(destination: CustomizedDataView(appManager: appManager)) {
                        Label("Customized Data", systemImage: "wand.and.stars")
                    }
                    
                    Picker(selection: $selectedCurrency) {
                        Text("USD").tag("USD")
                        Text("ILS").tag("ILS")
                        Text("EUR").tag("EUR")
                        Text("GBP").tag("GBP")
                    } label: {
                        Label("Select currency", systemImage: "dollarsign.circle")
//                        Text("Select currency")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedCurrency) { newValue in
                        print("---> saving currency")
                        AppManager.shared.saveCurrency(currency: selectedCurrency)
                    }
                }

                
                Section(header: Text("Notification center")) {
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("Notifications", systemImage: "bell")
                    }
                }
                
                Section(header: Text("Receipt center")) {
                    
                    NavigationLink(destination: ReceiptSettingsView(appManager: appManager, orderManager: orderManager)) {
                        Label("Receipt", systemImage: "folder")
                    }
                }

            }
            
            AdBannerView(adUnitID: "ca-app-pub-1213016211458907/1549825745")
                .frame(height: 50)
                .background(Color.white)
            // test: ca-app-pub-3940256099942544/2934735716
            
        }
        
    }
    
    
    private func updateAppearance() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        if darkModeOn {
            window?.overrideUserInterfaceStyle = .dark
        } else {
            window?.overrideUserInterfaceStyle = .light
        }
    }
    
}

extension String {
    var localized: LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}

#Preview {
    SettingsView(appManager: AppManager.shared, orderManager: OrderManager.shared)
}
