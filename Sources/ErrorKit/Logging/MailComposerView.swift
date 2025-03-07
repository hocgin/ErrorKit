#if canImport(MessageUI)
import SwiftUI
import MessageUI

/// A SwiftUI component that wraps UIKit's MFMailComposeViewController to provide email composition functionality in SwiftUI applications.
struct MailComposerView: UIViewControllerRepresentable {
   /// Checks if the device is capable of sending emails
   /// - Returns: Boolean indicating whether email composition is available
   static func canSendMail() -> Bool {
      MFMailComposeViewController.canSendMail()
   }

   @Binding var isPresented: Bool

   var recipients: [String]?
   var subject: String?
   var messageBody: String?
   var attachments: [MailAttachment]?

   func makeUIViewController(context: Context) -> MFMailComposeViewController {
      let composer = MFMailComposeViewController()
      composer.mailComposeDelegate = context.coordinator

      if let recipients {
         composer.setToRecipients(recipients)
      }

      if let subject {
         composer.setSubject(subject)
      }

      if let messageBody {
         composer.setMessageBody(messageBody, isHTML: false)
      }

      if let attachments {
         for attachment in attachments {
            composer.addAttachmentData(
               attachment.data,
               mimeType: attachment.mimeType,
               fileName: attachment.filename
            )
         }
      }

      return composer
   }

   func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

   func makeCoordinator() -> Coordinator {
      Coordinator(self)
   }

   class Coordinator: NSObject, @preconcurrency MFMailComposeViewControllerDelegate {
      var parent: MailComposerView

      init(_ parent: MailComposerView) {
         self.parent = parent
      }

      @MainActor
      func mailComposeController(
         _ controller: MFMailComposeViewController,
         didFinishWith result: MFMailComposeResult,
         error: Error?
      ) {
         self.parent.isPresented = false
         controller.dismiss(animated: true)
      }
   }
}
#endif
