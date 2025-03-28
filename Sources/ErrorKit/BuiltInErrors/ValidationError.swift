import Foundation

/// Represents errors related to validation failures.
///
/// # Examples of Use
///
/// ## Validating Form Input
/// ```swift
/// struct UserRegistrationValidator {
///     func validateUsername(_ username: String) throws(ValidationError) {
///         guard !username.isEmpty else {
///             throw .missingField(field: "Username")
///         }
///
///         guard username.count <= 30 else {
///             throw .inputTooLong(field: "Username", maxLength: 30)
///         }
///
///         guard isValidUsername(username) else {
///             throw .invalidInput(field: "Username")
///         }
///     }
/// }
/// ```
///
/// ## Handling Required Fields
/// ```swift
/// struct PaymentFormValidator {
///     func validatePaymentDetails(_ details: [String: String]) throws(ValidationError) {
///         guard let cardNumber = details["cardNumber"], !cardNumber.isEmpty else {
///             throw .missingField(field: "Card Number")
///         }
///         // Additional validation logic
///     }
/// }
/// ```
public enum ValidationError: Throwable, Catching {
   /// The input provided is invalid.
   ///
   /// # Example
   /// ```swift
   /// struct EmailValidator {
   ///     func validateEmail(_ email: String) throws(ValidationError) {
   ///         guard isValidEmailFormat(email) else {
   ///             throw .invalidInput(field: "Email Address")
   ///         }
   ///         // Additional email validation
   ///     }
   /// }
   /// ```
   /// - Parameters:
   ///   - field: The name of the field that caused the error.
   case invalidInput(field: String)

   /// A required field is missing.
   ///
   /// # Example
   /// ```swift
   /// struct ShippingAddressValidator {
   ///     func validateAddress(_ address: Address) throws(ValidationError) {
   ///         guard !address.street.isEmpty else {
   ///             throw .missingField(field: "Street Address")
   ///         }
   ///         // Additional address validation
   ///     }
   /// }
   /// ```
   /// - Parameters:
   ///   - field: The name of the required fields.
   case missingField(field: String)

   /// The input exceeds the maximum allowed length.
   ///
   /// # Example
   /// ```swift
   /// struct CommentValidator {
   ///     func validateComment(_ text: String) throws(ValidationError) {
   ///         guard text.count <= 1000 else {
   ///             throw .inputTooLong(field: "Comment", maxLength: 1000)
   ///         }
   ///         // Additional comment validation
   ///     }
   /// }
   /// ```
   /// - Parameters:
   ///   - field: The name of the field that caused the error.
   ///   - maxLength: The maximum allowed length for the field.
   case inputTooLong(field: String, maxLength: Int)

   /// Generic error message if the existing cases don't provide the required details.
   ///
   /// # Example
   /// ```swift
   /// struct CustomValidator {
   ///     func validateSpecialCase(_ input: String) throws(ValidationError) {
   ///         guard meetsCustomRequirements(input) else {
   ///             throw .generic(userFriendlyMessage: "Input does not meet requirements")
   ///         }
   ///         // Special validation logic
   ///     }
   /// }
   /// ```
   case generic(userFriendlyMessage: String)

   /// An error that occurred during validation, wrapped into this error type using the ``catch(_:)`` function.
   /// This could include data validation errors, format validation errors, or any other errors encountered during validation checks.
   ///
   /// # Example
   /// ```swift
   /// struct UserProfileValidator {
   ///     func validateProfile(_ profile: UserProfile) throws(ValidationError) {
   ///         // Regular error for field validation
   ///         guard !profile.name.isEmpty else {
   ///             throw ValidationError.missingField(field: "Name")
   ///         }
   ///
   ///         // Automatically wrap complex validation errors
   ///         try ValidationError.catch {
   ///             try emailValidator.validateEmailFormat(profile.email)
   ///             try addressValidator.validateAddress(profile.address)
   ///             try customFieldsValidator.validate(profile.customFields)
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
   ///   - error: The original error that occurred during the validation operation.
   case caught(Error)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .invalidInput(let field):
         return String.localized(
            key: "BuiltInErrors.ValidationError.invalidInput",
            defaultValue: "The value entered for \(field) is not in the correct format. Please review the requirements and try again."
         )
      case .missingField(let field):
         return String.localized(
            key: "BuiltInErrors.ValidationError.missingField",
            defaultValue: "Please provide a value for \(field). This information is required to proceed."
         )
      case .inputTooLong(let field, let maxLength):
         return String.localized(
            key: "BuiltInErrors.ValidationError.inputTooLong",
            defaultValue: "The \(field) field cannot be longer than \(maxLength) characters. Please shorten your input and try again."
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      case .caught(let error):
         return ErrorKit.userFriendlyMessage(for: error)
      }
   }
}
