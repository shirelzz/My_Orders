//
//  PDFPreviewView.swift
//  My Orders
//
//  Created by שיראל זכריה on 05/08/2024.
//

import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let pdfData: Data
    
    var body: some View {
        PDFKitRepresentedView(pdfData)
            .edgesIgnoringSafeArea(.all)
    }
}

struct PDFKitRepresentedView: UIViewRepresentable {
    let data: Data
    
    init(_ data: Data) {
        self.data = data
    }
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Update the view if needed
    }
}


#Preview {
    PDFPreviewView(pdfData: Data())
}
