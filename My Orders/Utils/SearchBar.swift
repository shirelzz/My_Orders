//
//  SearchBar.swift
//  My Orders
//
//  Created by שיראל זכריה on 02/10/2023.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            TextField("Search", text: $searchText)
                .padding(.leading, 10)
        }
        .padding(.vertical, 10)
        .background(Color(.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal, 10)
    }
}

#Preview {
    InventoryContentView(inventoryManager: InventoryManager.shared, tagManager: TagManager.shared)
}
