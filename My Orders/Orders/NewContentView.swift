import SwiftUI

struct NewContentView: View {

    @StateObject private var appManager = AppManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var orderManager = OrderManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared

    @State private var showAllOrders = false
    @State private var showAllReceipts = false
    @State private var isAddOrderViewPresented = false
    
    @State private var desserts: [Dessert] = []
    @State private var isSideMenuOpen = false
    @State private var showSideMenu = false

    init() {
        AppManager.shared.loadManagerData()
        OrderManager.shared.loadOrders()
        OrderManager.shared.loadReceipts()
        InventoryManager.shared.loadItems()
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                
                
                VStack (alignment: .trailing, spacing: 10) {
                    HStack {
                        
                        // Side Menu
                        SideMenuView(isSideMenuOpen: $isSideMenuOpen)
                            .frame(width: UIScreen.main.bounds.width / 2,
                                   alignment: .leading)
                            .offset(x: isSideMenuOpen ? 0 : -UIScreen.main.bounds.width)
                            .animation(Animation.easeInOut.speed(2), value: showSideMenu)
                        
                        // Hamburger Button
                        HStack {
                            Button(action: {
                                withAnimation {
                                    isSideMenuOpen.toggle()
                                }
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .padding()
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationBarTitle("Your App")
        }
    }
}

struct SideMenuView: View {
    @Binding var isSideMenuOpen: Bool
    
    @StateObject private var appManager = AppManager.shared
    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var orderManager = OrderManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared

    var body: some View {
        
        VStack {
            
            NavigationLink(destination: DashboardView(orderManager: orderManager, inventoryManager: inventoryManager)) {
                Label("Dashboard", systemImage: "chart.pie")
                    .padding()
            }
            
            NavigationLink(destination: AllOrdersView(orderManager: orderManager, languageManager: languageManager)) {
                Label("All orders", systemImage: "rectangle.stack")
                    .padding()
            }

            NavigationLink(destination: AllReceiptsView(orderManager: orderManager, languageManager: languageManager)) {
                Label("All receipts", systemImage: "tray.full")
                    .padding()
            }

            NavigationLink(destination: InventoryContentView()) {
                Label("Inventory", systemImage: "cube")
                    .padding()
            }

            NavigationLink(destination: SettingsView(appManager: appManager)) {
                Label("Settings", systemImage: "gear")
                    .padding()
            }
            
            Spacer()

            Button("x") {
                withAnimation {
                    isSideMenuOpen.toggle()
                }
                
            }
            .padding()
        }
        .background(Color.accentColor)
        .foregroundColor(.white)
        .opacity(1)
    }
}

struct NewContentView_Previews: PreviewProvider {
    static var previews: some View {
        NewContentView()
    }
}
