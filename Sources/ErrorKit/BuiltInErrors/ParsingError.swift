import Foundation

/// Represents errors that occur during parsing of input or data.
///
/// # Examples of Use
///
/// ## Handling Input Validation
/// ```swift
/// struct JSONParser {
///     func parse(rawInput: String) throws(ParsingError) -> ParsedData {
///         guard isValidJSONFormat(rawInput) else {
///             throw .invalidInput(input: rawInput)
///         }
///         // Parsing logic
///     }
/// }
/// ```
///
/// ## Managing Structured Data Parsing
/// ```swift
/// struct UserProfileParser {
///     func parseProfile(data: [String: Any]) throws(ParsingError) -> UserProfile {
///         guard let username = data["username"] else {
///             throw .missingField(field: "username")
///         }
///         // Profile parsing logic
///     }
/// }
/// ```
public enum ParsingError: Throwable, Catching {
   /// The input was invalid and could not be parsed.
   ///
   /// # Example
   /// ```swift
   /// struct ConfigurationParser {
   ///     func parseConfig(input: String) throws(ParsingError) -> Configuration {
   ///         guard isValidConfigurationFormat(input) else {
   ///             throw .invalidInput(input: input)
   ///         }
   ///         // Configuration parsing logic
   ///     }
   /// }
   /// ```
   /// - Parameter input: The invalid input string or description.
   case invalidInput(input: String)

   /// A required field was missing in the input.
   ///
   /// # Example
   /// ```swift
   /// struct PaymentProcessor {
   ///     func validatePaymentDetails(_ details: [String: String]) throws(ParsingError) {
   ///         guard details["cardNumber"] != nil else {
   ///             throw .missingField(field: "cardNumber")
   ///         }
   ///         // Payment processing logic
   ///     }
   /// }
   /// ```
   /// - Parameter field: The name of the missing field.
   case missingField(field: String)

   /// Generic error message if the existing cases don't provide the required details.
   ///
   /// # Example
   /// ```swift
   /// struct UnexpectedParsingHandler {
   ///     func handleUnknownParsingIssue() throws(ParsingError) {
   ///         guard !isHandledCase() else {
   ///             throw .generic(userFriendlyMessage: "An unexpected parsing error occurred")
   ///         }
   ///         // Fallback error handling
   ///     }
   /// }
   /// ```
   case generic(userFriendlyMessage: String)

   /// An error that occurred during parsing or data transformation, wrapped into this error type using the ``catch(_:)`` function.
   /// This could include JSON decoding errors, format validation errors, or any other errors encountered during data parsing.
   ///
   /// # Example
   /// ```swift
   /// struct ProfileParser {
   ///     func parseUserProfile(data: Data) throws(ParsingError) {
   ///         // Regular error for missing data
   ///         guard !data.isEmpty else {
   ///             throw ParsingError.missingField(field: "profile_data")
   ///         }
   ///
   ///         // Automatically wrap JSON decoding and validation errors
   ///         let profile = try ParsingError.catch {
   ///             let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
   ///             return try UserProfile(validating: json)
   ///         }
   ///     }
   /// }
   /// ```
   ///
   /// The `caught` case stores the original error while maintaining type safety through typed throws.
   /// Instead of manually catching and wrapping system errors, use the ``catch(_:)`` function
   /// which automatically wraps any thrown errors into this case.
   ///
   /// - Parameters:
   ///   - error: The original error that occurred during the parsing operation.
   case caught(Error)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .invalidInput(let input):
         return String.localized(
            key: "BuiltInErrors.ParsingError.invalidInput",
            defaultValue: "The provided input could not be processed correctly: \(input). Please review the input and ensure it matches the expected format."
         )
      case .missingField(let field):
         return String.localized(
            key: "BuiltInErrors.ParsingError.missingField",
            defaultValue: "The required information is incomplete. The \(field) field is missing and must be provided to continue."
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      case .caught(let error):
         return ErrorKit.userFriendlyMessage(for: error)
      }
   }
}
