//
//  SettingsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @ObservedObject var appManager: AppManager
//    @ObservedObject var languageManager: LanguageManager
    @ObservedObject var languageManager = LanguageManager.shared
    @ObservedObject var orderManager: OrderManager


    @State private var darkModeOn = false
    //    @State var selectedLanguage: String
    //    @State private var selectedLanguage = ""
    @State private var selectedLanguage: AppLanguage = LanguageManager.shared.currentLanguage
    
    
    var body: some View {
        
        NavigationStack{
            
            List{
                
                Section(header: Text("Personal Information".localized)) {
                    
                    NavigationLink(destination: AccountView()) {
                        Label(String(localized: "Account"), systemImage: "person")
                    }
                    
                    NavigationLink(destination: CustomizedDataView(appManager: appManager)) {
                        Label("Customized Data".localized, systemImage: "wand.and.stars")
                    }
                }
                
                Section(header: Text("Notification center".localized)) {
                    
                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("Notifications".localized, systemImage: "bell")
                    }
                }
                
                Section(header: Text("Receipt center".localized)) {
                    
                    NavigationLink(destination: ReceiptSettingsView(appManager: appManager, orderManager: orderManager)) {
                        Label("Receipt".localized, systemImage: "folder")
                    }
                }
                
                //                Section(header: Text("Language").localized()) {
                //
                //                    Picker("Select Language", selection: $selectedLanguage) {
                //                        Text("עברית").tag("עברית")
                //                        Text("English").tag("English")
                //                    }
                //                    .pickerStyle(DefaultPickerStyle())
                //                    .padding()
                //                    .onChange(of: selectedLanguage) { _ in
                //                        LanguageManager.shared.currentLanguage = AppLanguage(rawValue: selectedLanguage) ?? .english
                //                    }
                //                }
                
                //                Section(header: Text("Language")) {
                //                                    Picker("Select Language", selection: $selectedLanguage) {
                //                                        Text("English").tag(AppLanguage.english)
                //                                        Text("Hebrew").tag(AppLanguage.hebrew)
                //                                    }
                //                                    .pickerStyle(SegmentedPickerStyle())
                //                                    .onChange(of: selectedLanguage) { _ in
                //                                        LanguageManager.shared.currentLanguage = AppLanguage(rawValue: selectedLanguage) ?? .english
                //                                        // You might want to trigger a reload of your UI to reflect the language change
                //                                    }
                //                                }
                
                //                Section(header: Text(LocalizedStringKey("Language"))) {
                //                                    Picker("Select Language", selection: $selectedLanguage) {
                //                                        Text(LocalizedStringKey("english")).tag(AppLanguage.english)
                //                                        Text(LocalizedStringKey("hebrew")).tag(AppLanguage.hebrew)
                //                                    }
                //                                    .pickerStyle(SegmentedPickerStyle())
                //                                    .onChange(of: selectedLanguage) { newLanguage in
                //                                        if let language = AppLanguage(rawValue: newLanguage) {
                //                                                                    LanguageManager.shared.currentLanguage = language
                //                                                                }
                ////                                        LanguageManager.shared.currentLanguage = AppLanguage(rawValue: selectedLanguage) ?? .english
                //                                        // You might want to trigger a reload of your UI to reflect the language change
                //                                    }
                //                                }
                
                Section(header: Text("Language".localized)) {
                    //                    Picker("Select Language".localized, selection: $selectedLanguage) {
                    //                                    ForEach(AppLanguage.allCases, id: \.self.rawValue) { language in
                    //                                        Text(language.rawValue).tag(language.rawValue)
                    //                                    }
                    //                                }
                    Picker("Select Language".localized, selection: $selectedLanguage) {
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


//extension Text {
//    func localized() -> Text {
//        let keyString = String(describing: self)
//        let localizedString = NSLocalizedString(keyString, comment: "")
//        let preferredLocalizedStringKey = LocalizedStringKey(localizedString).applyingPreferredLocalization(language: LanguageManager.shared.currentLanguage)
//        return Text(preferredLocalizedStringKey)
//    }
//}
//
//
//extension LocalizedStringKey {
//    func applyingPreferredLocalization(language: AppLanguage) -> LocalizedStringKey {
//        // Convert LocalizedStringKey to String
//        let keyString = String(describing: self)
//
//        // Implement logic to fetch the correct localized string based on the selected language
//        let localizedString = NSLocalizedString(keyString, comment: "")
//
//        // Add logic to switch language and return the appropriate localized string
//        // You might use a custom localization manager or a switch statement here
//        return LocalizedStringKey(localizedString)
//    }
//}


extension String {
    var localized: LocalizedStringKey {
        return LocalizedStringKey(self)
    }
}


//extension Text {
//    func localized() -> Text {
//        return self
//    }
//}
//
//
//extension LocalizedStringKey {
//    func applyingPreferredLocalization(language: AppLanguage) -> LocalizedStringKey {
//        let keyString = String(describing: self)
//        let localizedString = NSLocalizedString(keyString, comment: "")
//        return LocalizedStringKey(localizedString)
//    }
//}



//#Preview {
//    SettingsView()
//}
