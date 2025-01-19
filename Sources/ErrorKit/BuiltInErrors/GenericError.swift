import Foundation

/// Represents a generic error with a custom user-friendly message.
/// Use this when the built-in error types don't match your specific error case
/// or when you need a simple way to throw custom error messages.
///
/// # Examples of Use
///
/// ## Custom Business Logic Validation
/// ```swift
/// struct BusinessRuleValidator {
///     func validateComplexRule(data: BusinessData) throws(GenericError) {
///         guard meetsCustomCriteria(data) else {
///             throw GenericError(
///                 userFriendlyMessage: String(localized: "The business data doesn't meet required criteria")
///             )
///         }
///
///         // Automatically wrap any other errors if needed
///         try GenericError.catch {
///             try validateAdditionalRules(data)
///         }
///     }
/// }
/// ```
///
/// ## Application-Specific Errors
/// ```swift
/// struct CustomProcessor {
///     func processSpecialCase() throws(GenericError) {
///         guard canHandleSpecialCase() else {
///             throw GenericError(
///                 userFriendlyMessage: String(localized: "Unable to process this special case")
///             )
///         }
///         // Special case handling
///     }
/// }
/// ```
public struct GenericError: Throwable, Catching {
   /// A user-friendly message describing the error.
   public let userFriendlyMessage: String

   /// Creates a new generic error with a custom user-friendly message.
   ///
   /// # Example
   /// ```swift
   /// struct CustomValidator {
   ///     func validateSpecialRequirement() throws(GenericError) {
   ///         guard meetsRequirement() else {
   ///             throw GenericError(
   ///                 userFriendlyMessage: String(localized: "The requirement was not met. Please try again.")
   ///             )
   ///         }
   ///         // Validation logic
   ///     }
   /// }
   /// ```
   /// - Parameter userFriendlyMessage: A clear, actionable message that will be shown to the user.
   public init(userFriendlyMessage: String) {
      self.userFriendlyMessage = userFriendlyMessage
   }

   /// Creates a new generic error that wraps another error.
   /// Used internally by the ``catch(_:)`` function to automatically wrap any thrown errors.
   ///
   /// # Example
   /// ```swift
   /// struct FileProcessor {
   ///     func processUserData() throws(GenericError) {
   ///         // Explicit throwing for validation
   ///         guard isValidPath(userDataPath) else {
   ///             throw GenericError(userFriendlyMessage: "Invalid file path selected")
   ///         }
   ///
   ///         // Automatically wrap any file system or JSON errors
   ///         let userData = try GenericError.catch {
   ///             let data = try Data(contentsOf: userDataPath)
   ///             return try JSONDecoder().decode(UserData.self, from: data)
   ///         }
   ///     }
   /// }
   /// ```
   ///
   /// - Parameter error: The error to be wrapped.
   public static func caught(_ error: Error) -> Self {
      GenericError(userFriendlyMessage: ErrorKit.userFriendlyMessage(for: error))
   }
}
