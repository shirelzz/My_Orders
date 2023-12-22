import SwiftUI

struct NewContentView: View {

    @StateObject private var appManager = AppManager.shared
//    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var orderManager = OrderManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared

    @State private var showAllOrders = false
    @State private var showAllReceipts = false
    @State private var isAddOrderViewPresented = false
    
    @State private var orderItems: [OrderItem] = []
    @State private var isSideMenuOpen = false
    @State private var showSideMenu = false

    init() {
        AppManager.shared.loadManagerData()
        OrderManager.shared.loadOrders()
        OrderManager.shared.loadReceipts()
        InventoryManager.shared.loadItemsFromUD()
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
                .contentShape(Rectangle()) // Enable tap gesture on entire content area
                                .onTapGesture {
                                    if isSideMenuOpen {
                                        withAnimation {
                                            isSideMenuOpen = false
                                        }
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
//    @StateObject private var languageManager = LanguageManager.shared
    @StateObject private var orderManager = OrderManager.shared
    @StateObject private var inventoryManager = InventoryManager.shared

    var body: some View {
        
        NavigationStack{
            
            VStack(alignment: .leading, spacing: 30) {
                
                Spacer(minLength: 10)
                
                Image(uiImage: UIImage(data: appManager.manager.logoImgData ?? Data()) ?? UIImage())
                    .resizable(capInsets: EdgeInsets())
                    .frame(width: 70, height: 70)
                    .cornerRadius(30)
                    .padding(.leading, 60)
                
                Spacer()
                
                NavigationLink(destination: DashboardView(orderManager: orderManager, inventoryManager: inventoryManager)
                    .onAppear {
                        isSideMenuOpen = false
                    }) {
                    Label("Dashboard", systemImage: "chart.pie")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.white)
//                        .padding()
                }
               
                
                NavigationLink(destination: AllOrdersView(orderManager: orderManager, inventoryManager: inventoryManager)
                    .onAppear {
                        isSideMenuOpen = false
                    }) {
                    Label("All orders", systemImage: "rectangle.stack")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.white)
//                        .padding(.leading)
                }
                
                NavigationLink(destination: AllReceiptsView(orderManager: orderManager)
                    .onAppear {
                        isSideMenuOpen = false
                    }) {
                    Label("All receipts", systemImage: "tray.full")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.white)
//                        .padding(.leading)
                }
                
                NavigationLink(destination: InventoryContentView(inventoryManager: inventoryManager)
                    .onAppear {
                        isSideMenuOpen = false
                    }) {
                    Label("Inventory",
                          systemImage: "cube")
                    .font(.system(size: 20))
                    .bold()
                    .foregroundColor(.white)
//                    .padding(.leading)
                }
                
                NavigationLink(destination: SettingsView(appManager: appManager, orderManager: orderManager)
                    .onAppear {
                        isSideMenuOpen = false
                    }) {
                    Label("Settings", systemImage: "gear")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.white)
//                        .padding(.leading)
                }
                
                Spacer()
                

//                .font(.system(size: 22))
//                .bold()
//                .foregroundColor(.white)
//                .padding()
            }
//            .background(Color.accentColor)
//            .foregroundColor(.white)
//            .opacity(1)
            
            .padding(.leading, -45) // Adjust top padding
            .frame(width: 240) // Set a fixed width for the side menu
            .background(LinearGradient(gradient: Gradient(colors: [.white.opacity(1), .accentColor.opacity(1)]), startPoint: .top, endPoint: .bottom)) // Use a gradient background
            .foregroundColor(.white)
            .cornerRadius(16) // Add rounded corners
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 10) // Add a slight shadow effect
            .opacity(1)
//            .multilineTextAlignment() // Make the text left-aligned
            .lineSpacing(10)
        }
    }
}

struct NewContentView_Previews: PreviewProvider {
    static var previews: some View {
        NewContentView()
    }
}
