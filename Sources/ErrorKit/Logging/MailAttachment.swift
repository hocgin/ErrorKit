import Foundation

/// Represents an email attachment with data, mime type, and filename
public struct MailAttachment {
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
