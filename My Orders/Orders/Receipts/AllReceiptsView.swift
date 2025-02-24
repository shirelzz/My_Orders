import SwiftUI
import GoogleMobileAds
import ZipArchive

struct AllReceiptsView: View {
    
    @ObservedObject var orderManager: OrderManager
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var isExporting: Bool = false
    @State private var searchText = ""
    @State private var isAddItemViewPresented = false
    @State private var sortOption: SortOption = .newest
    
    enum SortOption: String, CaseIterable {
        case name = "Name"
        case newest = "New to Old"
        case oldest = "Old to New"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                searchAndSortSection
                receiptList
                adBanner
            }
            .navigationTitle("All Receipts")
            .toolbar {
                yearPicker
                exportButton
                addItemButton
            }
        }
    }
    
    private var searchAndSortSection: some View {
        VStack {
            HStack {
                Menu {
                    Picker("Sort By", selection: $sortOption) {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue.localized)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                
                SearchBar(searchText: $searchText)
            }
            .padding(8)
            .background {
                Image("receipts")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.top)
                    .opacity(0.2)
                    .frame(height: 200)
            }
        }
    }
    
    private var receiptList: some View {
        List(filteredAndSortedReceipts) { receipt in
            if let order = orderManager.orders.first(where: { $0.orderID == receipt.orderID }) {
                NavigationLink(destination: GeneratedReceiptView(orderManager: orderManager, order: order, isPresented: .constant(false))) {
                    ReceiptRowView(order: order, receipt: receipt)
                }
            }
        }
        .listStyle(.plain)
        .refreshable {
            await refreshReceipts()
        }
    }
    
    private var adBanner: some View {
        AdBannerView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
            .frame(height: 50)
            .background(Color.white)
    }
    
    private var yearPicker: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Picker("", selection: $selectedYear) {
                ForEach(2020...2030, id: \.self) {
                    Text(String($0)).bold()
                }
            }
        }
    }
    
    private var exportButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: exportReceipts) {
                Text("Export")
            }
            .foregroundColor(.accentColor)
            .disabled(isExporting)
        }
    }
    
    private var addItemButton: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: { isAddItemViewPresented = true }) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 20))
            }
            .sheet(isPresented: $isAddItemViewPresented) {
                AddReceiptView(orderManager: orderManager, isPresented: $isAddItemViewPresented)
            }
        }
    }
    
    private func exportReceipts() {
        guard !isExporting else { return }
        isExporting = true
        
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        if let viewController = window?.rootViewController {
            ReceiptUtils.exportReceiptsAsCSV(orderManager: orderManager, selectedYear: selectedYear, viewController: viewController) {_,_ in
                isExporting = false
            }
        }
    }
    
    private var filteredAndSortedReceipts: [Receipt] {
        let filtered = orderManager.getReceipts(forYear: selectedYear)
            .filter { receipt in
                let order = orderManager.getOrderFromID(forOrderID: receipt.orderID)
                
                // Check if searchText is a number
                if let searchAmount = Double(searchText) {
                    // Filter by totalPrice if searchText is a number
                    return order.totalPrice == searchAmount
                } else {
                    // Otherwise, filter by customer name
                    return searchText.isEmpty || order.customer.name.localizedCaseInsensitiveContains(searchText)
                }
            }
        
        switch sortOption {
        case .name:
            return filtered.sorted { orderManager.getOrderFromID(forOrderID: $0.orderID).customer.name < orderManager.getOrderFromID(forOrderID: $1.orderID).customer.name }
        case .newest:
            return filtered.sorted { $0.myID > $1.myID }
        case .oldest:
            return filtered.sorted { $0.myID < $1.myID }
        }
    }
    
    func refreshReceipts() async {
        AppManager.shared.refreshCurrency()
        orderManager.fetchReceipts()
    }
}
