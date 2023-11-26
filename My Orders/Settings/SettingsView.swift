//
//  SettingsView.swift
//  My Orders
//
//  Created by שיראל זכריה on 26/11/2023.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var darkModeOn = false

    
    var body: some View {
        
        NavigationStack{
            
            List{
                
                Section(header: Text("Personal Information")) {
                        
//                        HStack{
                            NavigationLink(destination: AccountView()) {
                                Label("Account", systemImage: "person")
                                }
//                        }
                        
    //                    HStack{
                            NavigationLink(destination: SignatureView()) {
                                Label("Customized Data", systemImage: "wand.and.stars")
                                }
    //                    }
                        
                }
                
                Section(header: Text("Display")) {

                    VStack {
                        
                        HStack {
                            
                            Toggle("Dark Mode", systemImage: "moon", isOn: $darkModeOn)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .onChange(of: darkModeOn) { _ in
                                    updateAppearance()
                                }
                            
                            
                        }
                        
                    }
                }
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

#Preview {
    SettingsView()
}
