import Foundation

/// Represents errors that occur during parsing of input or data.
public enum ParsingError: Throwable {
   /// The input was invalid and could not be parsed.
   /// - Parameter input: The invalid input string or description.
   case invalidInput(input: String)

   /// A required field was missing in the input.
   /// - Parameter field: The name of the missing field.
   case missingField(field: String)

   /// Generic error message if the existing cases don't provide the required details.
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .invalidInput(let input):
         return String(
            localized: "BuiltInErrors.ParsingError.invalidInput",
            defaultValue: "The provided input is invalid: \(input). Please correct it and try again.",
            bundle: .module
         )
      case .missingField(let field):
         return String(
            localized: "BuiltInErrors.ParsingError.missingField",
            defaultValue: "A required field is missing: \(field). Please review and try again.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
