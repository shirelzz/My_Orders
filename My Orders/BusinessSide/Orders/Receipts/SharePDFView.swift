//
//  SharePDFView.swift
//  My Orders
//
//  Created by שיראל זכריה on 03/10/2023.
//

import SwiftUI
import UIKit

struct SharePDFView: UIViewControllerRepresentable {
    
    let pdfData: Data

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Not needed for this example
    }
}
