import Foundation

/// Represents errors related to validation failures.
public enum ValidationError: Throwable {
   /// The input provided is invalid.
   /// - Parameters:
   ///   - field: The name of the field that caused the error.
   case invalidInput(field: String)

   /// A required field is missing.
   /// - Parameters:
   ///   - field: The name of the required fields.
   case missingField(field: String)

   /// The input exceeds the maximum allowed length.
   /// - Parameters:
   ///   - field: The name of the field that caused the error.
   ///   - maxLength: The maximum allowed length for the field.
   case inputTooLong(field: String, maxLength: Int)

   /// Generic error message if the existing cases don't provide the required details.
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .invalidInput(let field):
         return String(
            localized: "BuiltInErrors.ValidationError.invalidInput",
            defaultValue: "The value provided for \(field) is invalid. Please correct it.",
            bundle: .module
         )
      case .missingField(let field):
         return String(
            localized: "BuiltInErrors.ValidationError.missingField",
            defaultValue: "\(field) is a required field. Please provide a value.",
            bundle: .module
         )
      case .inputTooLong(let field, let maxLength):
         return String(
            localized: "BuiltInErrors.ValidationError.inputTooLong",
            defaultValue: "\(field) exceeds the maximum allowed length of \(maxLength) characters. Please shorten it.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
