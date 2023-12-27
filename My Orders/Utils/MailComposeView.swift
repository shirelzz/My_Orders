//
//  MailComposeView.swift
//  My Orders
//
//  Created by שיראל זכריה on 25/12/2023.
//

import SwiftUI
import MessageUI

//struct MailComposeView: UIViewControllerRepresentable {
//    let subject: String
//    let body: String
//    let onDismiss: () -> Void
//
//    func makeUIViewController(context: Context) -> MFMailComposeViewController {
//        let viewController = MFMailComposeViewController()
//        viewController.setSubject(subject)
//        viewController.setMessageBody(body, isHTML: false)
//        viewController.setToRecipients(["uni.shirz21@gmail.com"])
//        viewController.mailComposeDelegate = context.coordinator
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//        var parent: MailComposeView
//
//        init(parent: MailComposeView) {
//            self.parent = parent
//        }
//
//        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//            parent.onDismiss()
//        }
//    }
//}

//struct MailComposeView: UIViewControllerRepresentable {
//    let subject: String
//    let body: String
//    @Binding var isMailComposePresented: Bool
//
//
//    func makeUIViewController(context: Context) -> UIViewController {
//        guard MFMailComposeViewController.canSendMail() else {
//            // Handle the case where the device cannot send mail
//            // You might want to display an alert or provide alternative options
//            return UIViewController()
//        }
//
//        let viewController = MFMailComposeViewController()
//        viewController.setSubject(subject)
//        viewController.setMessageBody(body, isHTML: false)
//        viewController.setToRecipients(["your_email@example.com"])
//        viewController.mailComposeDelegate = context.coordinator
//        return viewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(parent: self)
//    }
//
//    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
//        var parent: MailComposeView
//
//        init(parent: MailComposeView) {
//            self.parent = parent
//        }
//
//        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
//            parent.isMailComposePresented = false
//        }
//    }
//}

//#Preview {
//    MailComposeView(subject: <#String#>, body: <#String#>)
//}
