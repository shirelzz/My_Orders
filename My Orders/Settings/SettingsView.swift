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
                    
//                    Button {
//                        do {
//                        let userID = "Piggy123world"
//                        print("--> userID: \(userID)")
//                        let publicID = try Encryption.encryptID(userID: userID)
//                        print("--> publicID: \(publicID)")
//                        let decryptedPublicID = try Encryption.decryptID(encryptedID: publicID)
//                        print("--> decrypted: \(decryptedPublicID)")
//                    } catch {
//                        print("Error encrypting ID: \(error)")
//                    }
//                    } label: {
//                        Text("test encryption")
//                    }
                    
                }
                
                Section {
                    Picker(selection: $selectedCurrency) {
                        Text("USD").tag("USD")
                        Text("ILS").tag("ILS")
                        Text("EUR").tag("EUR")
                        Text("GBP").tag("GBP")
                    } label: {
                        Label("Select currency", systemImage: "dollarsign.circle")
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedCurrency) { newValue in
                        AppManager.shared.saveCurrency(currency: selectedCurrency)
                    }
                } footer: {
//                    Text("You might need to relaunch the app before you see this change through all screens")
                }
                
//                Section(header: Text("Notification center")) {
//                    
//                    NavigationLink(destination: NotificationSettingsView()) {
//                        Label("Notifications", systemImage: "bell")
//                    }
//                }
                
                Section(header: Text("Receipt center")) {
                    
                    NavigationLink(destination: ReceiptSettingsView(appManager: appManager, orderManager: orderManager)) {
                        Label("Receipt", systemImage: "folder")
                    }
                }

            }
            
            
            
            AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
                .frame(height: 50)
                .background(Color.white)
            // test: ca-app-pub-3940256099942544/2934735716
            // mine: ca-app-pub-1213016211458907/1549825745
            
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
