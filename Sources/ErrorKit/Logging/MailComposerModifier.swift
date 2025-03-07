#if canImport(MessageUI)
import SwiftUI
import MessageUI

/// A view modifier that presents a mail composer for sending emails with attachments.
/// This modifier is particularly useful for implementing feedback or bug reporting features.
struct MailComposerModifier: ViewModifier {
   @Environment(\.dismiss) private var dismiss

   @Binding var isPresented: Bool

   var recipient: String
   var subject: String?
   var messageBody: String?
   var attachments: [MailAttachment]?

   func body(content: Content) -> some View {
      content
         .sheet(isPresented: self.$isPresented) {
            if MailComposerView.canSendMail() {
               MailComposerView(
                  isPresented: self.$isPresented,
                  recipients: [self.recipient],
                  subject: self.subject,
                  messageBody: self.messageBody,
                  attachments: self.attachments
               )
            } else {
               VStack(spacing: 20) {
                  Text(
                     String(
                        localized: "Logging.MailComposer.notAvailableTitle",
                        defaultValue: "Mail Not Available",
                        bundle: .module
                     )
                  )
                  .font(.headline)

                  Text(
                     String(
                        localized: "Logging.MailComposer.notAvailableMessage",
                        defaultValue: "Your device is not configured to send emails. Please set up the Mail app or use another method to contact support at: \(self.recipient)",
                        bundle: .module,
                        comment: "%@ is typically replaced by the email address of the support contact, e.g. 'support@example.com' – so this would read like '... contact support at: support@example.com'"
                     )
                  )
                  .multilineTextAlignment(.center)
                  .padding(.horizontal)

                  Button(
                     String(
                        localized: "Logging.MailComposer.dismissButton",
                        defaultValue: "Dismiss",
                        bundle: .module
                     )
                  ) {
                     self.dismiss()
                  }
                  .buttonStyle(.borderedProminent)
               }
               .padding()
            }
         }
   }
}

/// Extension that adds the mailComposer modifier to any SwiftUI view.
extension View {
   /// Presents a mail composer when a binding to a Boolean value becomes `true`.
   ///
   /// Use this modifier to present an email composition interface with optional
   /// recipients, subject, message body, and attachments (such as log files).
   ///
   /// # Example
   /// ```swift
   /// struct ContentView: View {
   ///     @State private var showMailComposer = false
   ///
   ///     var body: some View {
   ///         Button("Report Problem") {
   ///             showMailComposer = true
   ///         }
   ///         .mailComposer(
   ///             isPresented: $showMailComposer,
   ///             recipient: "support@yourapp.com",
   ///             subject: "App Feedback",
   ///             messageBody: "I encountered an issue while using the app:",
   ///             attachments: [try? ErrorKit.logAttachment(ofLast: .minutes(10))].compactMap { $0 }
   ///         )
   ///     }
   /// }
   /// ```
   ///
   /// - Parameters:
   ///   - isPresented: A binding to a Boolean value that determines whether to present the mail composer.
   ///   - recipient: The email address to include in the "To" field.
   ///   - subject: The subject line of the email.
   ///   - messageBody: The content of the email message.
   ///   - attachments: An array of attachments to include with the email.
   /// - Returns: A view that presents a mail composer when `isPresented` is `true`.
   public func mailComposer(
      isPresented: Binding<Bool>,
      recipient: String,
      subject: String? = nil,
      messageBody: String? = nil,
      attachments: [MailAttachment]? = nil
   ) -> some View {
      self.modifier(
         MailComposerModifier(
            isPresented: isPresented,
            recipient: recipient,
            subject: subject,
            messageBody: messageBody,
            attachments: attachments
         )
      )
   }
}
#endif
