//
//  CustomCheckBox.swift
//  My Orders
//
//  Created by שיראל זכריה on 23/01/2024.
//

import SwiftUI

struct CheckboxToggle: View {
    @Binding var isOn: [String]
    let tag: String

    var body: some View {
        Toggle(isOn: Binding(
            get: { isOn.contains(tag) },
            set: { newValue in
                if newValue {
                    isOn.append(tag)
                } else {
                    isOn.removeAll { $0 == tag }
                }
            }
        )) {
            Text(tag.localized)
                .foregroundStyle(.primary)
        }
    }
}

struct iOSCheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {

            configuration.isOn.toggle()

        }, label: {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")

                configuration.label
            }
        })
    }
}
