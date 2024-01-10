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
                }
                
//                Section(header: Text("Data Management")) {
//                    
//                    Button("Clear Delivered Orders") {
//                        orderManager.clearDeliveredOrders()
//                    }
//
//                    Button("Clear Out-of-Stock Items") {
//                        InventoryManager.shared.clearOutOfStockItems()
//                    }
////                    NavigationLink(destination: ManageDataView()) {
////                        Label("Manage Data", systemImage: "folder")
////                    }
//                }

                
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
                
                Section(header: Text("Feedback")) {
                    Button(action: {
                        rateApp()
                    }) {
                        Text("Rate Us  🤍")
                    }
                    
                    NavigationLink("Send Suggestions", destination: FeedbackView())

                }
                
//                Section(header: Text("Language")) {
//    
//                    Picker("Select Language", selection: $selectedLanguage) {
//                        ForEach(AppLanguage.allCases, id: \.self) { language in
//                            Text(language.rawValue)
//                        }
//                    }
//                    .pickerStyle(SegmentedPickerStyle())
//                    .background(Color.accentColor.opacity(0.3).cornerRadius(13.0))
//                    .cornerRadius(3.0)
//                    .onChange(of: selectedLanguage) { newLanguage in
//                        if let language = AppLanguage(rawValue: newLanguage.rawValue) {
//                            languageManager.currentLanguage = language
//                        }
//                    }
//                }
                
                
                //                Section(header: Text("Display")) {
                //
                //                    VStack {
                //
                //                        HStack {
                //
                //                            Toggle("Dark Mode", systemImage: "moon", isOn: $darkModeOn)
                //                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                //                                .onChange(of: darkModeOn) { _ in
                //                                    updateAppearance()
                //                                }
                //
                //                        }
                //
                //                    }
                //                }
            }
            
            AdBannerView(adUnitID: "ca-app-pub-1213016211458907/1549825745")
                .frame(height: 50)
                .background(Color.white)
            // test: ca-app-pub-3940256099942544/2934735716
            
        }
        
    }
    
    func rateApp() {
            guard let appURL = URL(string: "https://apps.apple.com/il/app/candy-crush-soda-saga/id850417475") else { return }
            
            if UIApplication.shared.canOpenURL(appURL) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appURL)
                }
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
