//
//  SettingsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var appManager: AppManager
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var orderManager: OrderManager


    @State private var darkModeOn = false
    @State private var selectedLanguage: AppLanguage = LanguageManager.shared.currentLanguage
    
    
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
                
                Section(header: Text("Language")) {
    
                    Picker("Select Language", selection: $selectedLanguage) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .background(Color.accentColor.opacity(0.3).cornerRadius(13.0))
                    .cornerRadius(3.0)
                    .onChange(of: selectedLanguage) { newLanguage in
                        if let language = AppLanguage(rawValue: newLanguage.rawValue) {
                            languageManager.currentLanguage = language
                        }
                    }
                }
                
                
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
