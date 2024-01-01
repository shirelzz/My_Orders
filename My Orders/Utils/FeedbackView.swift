//
//  FeedbackView.swift
//  My Orders
//
//  Created by שיראל זכריה on 25/12/2023.
//

import SwiftUI
import MessageUI

import SwiftUI
import MessageUI

struct FeedbackView: View {
    @State private var suggestionText = ""
    @State private var isMailComposePresented = false

    var body: some View {
        ZStack {
            // Your main content here

            VStack {
                Spacer()

                // FeedbackView
                FeedbackSheetView(
                    suggestionText: $suggestionText,
                    isMailComposePresented: $isMailComposePresented
                )
                .offset(y: isMailComposePresented ? 0 : UIScreen.main.bounds.height)
                .opacity(isMailComposePresented ? 1 : 0)
                .animation(.easeInOut, value: 0.5)
            }
        }
    }
}

struct FeedbackSheetView: View {
    @Binding var suggestionText: String
    @Binding var isMailComposePresented: Bool

    var body: some View {
        VStack {
            // Your feedback form content here

            Button(action: {
                sendSuggestions()
            }) {
                Text("Send Suggestions")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(suggestionText.isEmpty)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .sheet(isPresented: $isMailComposePresented) {
            MailComposeView(subject: "User Suggestions", body: suggestionText) {
                // This closure will be called when the user dismisses the mail compose view
                isMailComposePresented = false
            }
        }
    }

    func sendSuggestions() {
        isMailComposePresented.toggle()
    }
}

struct MailComposeView: UIViewControllerRepresentable {
    let subject: String
    let body: String
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        guard MFMailComposeViewController.canSendMail() else {
            // Handle the case where the device cannot send mail
            // You might want to display an alert or provide alternative options
            return UIViewController()
        }

        let viewController = MFMailComposeViewController()
        viewController.setSubject(subject)
        viewController.setMessageBody(body, isHTML: false)
        viewController.setToRecipients(["uni.shirz21@gmail.com"])
        viewController.mailComposeDelegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposeView

        init(parent: MailComposeView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.onDismiss()
        }
    }
}

//
//struct FeedbackView: View {
//    @State private var suggestionText = ""
//    @State private var isMailComposePresented = false
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Form {
//                    Section(header: Text("Suggestions")) {
//                        TextEditor(text: $suggestionText)
//                            .frame(minHeight: 100)
//                    }
//                    
//                        Button(action: {
//                            sendSuggestions()
//                        }) {
//                            Text("Send Suggestions")
//                                .foregroundColor(.white)
//                                .padding()
//                                .frame(maxWidth: .infinity)
//                                .background(Color.accentColor)
//                                .cornerRadius(30)
//                        }
//                        .disabled(suggestionText.isEmpty)
//                    
//                }
//                .navigationTitle("Send Suggestions")
//                .sheet(isPresented: $isMailComposePresented) {
//                    MailComposeView(subject: "User Suggestions", body: suggestionText, isMailComposePresented: $isMailComposePresented)
//                }
//            }
//        }
//    }
//    
//    func sendSuggestions() {
//        isMailComposePresented.toggle()
//    }

//    func sendSuggestions() {
//        // Present mail compose view
//        isMailComposePresented = true
//    }
//}


#Preview {
    FeedbackView()
}
