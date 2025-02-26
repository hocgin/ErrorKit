import SwiftUI
import MessageUI

/// A SwiftUI component that wraps UIKit's MFMailComposeViewController to provide email
/// composition functionality in SwiftUI applications.
///
/// # Example
///
/// ```swift
/// struct ContentView: View {
///     @State private var showingMail = false
///     @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
///
///     var body: some View {
///         Button("Contact Support") {
///             if MailView.canSendMail() {
///                 showingMail = true
///             }
///         }
///         .sheet(isPresented: $showingMail) {
///             MailView(
///                 isShowing: $showingMail,
///                 result: $mailResult,
///                 recipients: ["support@example.com"],
///                 subject: "App Feedback",
///                 messageBody: "I'm enjoying the app, but found an issue:",
///                 attachments: [
///                     MailView.Attachment(
///                         data: UIImage(named: "screenshot")!.pngData()!,
///                         mimeType: "image/png",
///                         filename: "screenshot.png"
///                     )
///                 ]
///             )
///         }
///     }
/// }
/// ```
public struct MailView: UIViewControllerRepresentable {
   /// Represents an email attachment with data, mime type, and filename
   public struct Attachment {
      let data: Data
      let mimeType: String
      let filename: String

      /// Creates a new email attachment
      /// - Parameters:
      ///   - data: The content of the attachment as Data
      ///   - mimeType: The MIME type of the attachment (e.g., "image/jpeg", "application/pdf")
      ///   - filename: The filename for the attachment when received by the recipient
      public init(data: Data, mimeType: String, filename: String) {
         self.data = data
         self.mimeType = mimeType
         self.filename = filename
      }
   }

   /// Checks if the device is capable of sending emails
   /// - Returns: Boolean indicating whether email composition is available
   public static func canSendMail() -> Bool {
      MFMailComposeViewController.canSendMail()
   }

   @Binding private var isShowing: Bool

   private var recipients: [String]?
   private var subject: String?
   private var messageBody: String?
   private var isHTML: Bool
   private var attachments: [Attachment]?

   /// Creates a new mail view with the specified parameters
   /// - Parameters:
   ///   - isShowing: Binding to control the presentation state
   ///   - result: Binding to capture the result of the mail composition
   ///   - recipients: Optional array of recipient email addresses
   ///   - subject: Optional subject line
   ///   - messageBody: Optional body text
   ///   - isHTML: Whether the message body contains HTML (defaults to false)
   ///   - attachments: Optional array of attachments
   public init(
      isShowing: Binding<Bool>,
      result: Binding<Result<MFMailComposeResult, Error>?>,
      recipients: [String]? = nil,
      subject: String? = nil,
      messageBody: String? = nil,
      isHTML: Bool = false,
      attachments: [Attachment]? = nil
   ) {
      self._isShowing = isShowing
      self.recipients = recipients
      self.subject = subject
      self.messageBody = messageBody
      self.isHTML = isHTML
      self.attachments = attachments
   }

   public func makeUIViewController(context: Context) -> MFMailComposeViewController {
      let composer = MFMailComposeViewController()
      composer.mailComposeDelegate = context.coordinator

      if let recipients = recipients {
         composer.setToRecipients(recipients)
      }

      if let subject = subject {
         composer.setSubject(subject)
      }

      if let messageBody = messageBody {
         composer.setMessageBody(messageBody, isHTML: isHTML)
      }

      if let attachments = attachments {
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

   public func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

   public func makeCoordinator() -> Coordinator {
      Coordinator(self)
   }

   public class Coordinator: NSObject, @preconcurrency MFMailComposeViewControllerDelegate {
      var parent: MailView

      init(_ parent: MailView) {
         self.parent = parent
      }

      @MainActor
      public func mailComposeController(
         _ controller: MFMailComposeViewController,
         didFinishWith result: MFMailComposeResult,
         error: Error?
      ) {
         parent.isShowing = false
         controller.dismiss(animated: true)
      }
   }
}
