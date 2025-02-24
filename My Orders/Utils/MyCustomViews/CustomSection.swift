//
//  CustomSection.swift
//  My Orders
//
//  Created by שיראל זכריה on 12/11/2024.
//

import SwiftUI

struct CustomSection<Content: View>: View {
    var header: String
    var headerColor: Color
    var content: Content

    init(header: String, headerColor: Color, @ViewBuilder content: () -> Content) {
        self.header = header
        self.headerColor = headerColor
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header Text
            Text(header)
                .foregroundColor(headerColor)
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.leading)

            // Section Content
            VStack(alignment: .leading) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity) // Makes the content expand to the full width of the section
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal) // Padding from the screen edges
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Ensures the section takes up the full width
    }
}



//#Preview {
//    CustomSection(header: "String", headerColor: Color.primary, content: {
//        Text("something hvjvhjvjhvhjvhjvhvhvhhv")
//    })
//}
