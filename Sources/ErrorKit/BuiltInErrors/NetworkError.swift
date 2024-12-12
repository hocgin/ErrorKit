import Foundation

/// Represents errors that can occur during network operations.
public enum NetworkError: Throwable {
   /// No internet connection is available.
   /// - Note: This error may occur if the device is in airplane mode or lacks network connectivity.
   case noInternet

   /// The request timed out before completion.
   case timeout

   /// The server responded with a bad request error.
   /// - Parameters:
   ///   - code: The exact HTTP status code returned by the server.
   ///   - message: An error message provided by the server in the body.
   case badRequest(code: Int, message: String)

   /// The server responded with a general server-side error.
   /// - Parameters:
   ///   - code: The HTTP status code returned by the server.
   ///   - message: An optional error message provided by the server.
   case serverError(code: Int, message: String?)

   /// The response could not be decoded or parsed.
   case decodingFailure

   /// Generic error message if the existing cases don't provide the required details.
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .noInternet:
         return String(
            localized: "BuiltInErrors.NetworkError.noInternet",
            defaultValue: "No internet connection is available. Please check your network settings and try again.",
            bundle: .module
         )
      case .timeout:
         return String(
            localized: "BuiltInErrors.NetworkError.timeout",
            defaultValue: "The request timed out. Please try again later.",
            bundle: .module
         )
      case .badRequest(let code, let message):
         return String(
            localized: "BuiltInErrors.NetworkError.badRequest",
            defaultValue: "The request was malformed (\(code)): \(message). Please review and try again.",
            bundle: .module
         )
      case .serverError(let code, let message):
         let defaultMessage = String(
            localized: "BuiltInErrors.NetworkError.serverError",
            defaultValue: "The server encountered an error (Code: \(code)).",
            bundle: .module
         )
         if let message = message {
            return defaultMessage + " " + message
         } else {
            return defaultMessage
         }
      case .decodingFailure:
         return String(
            localized: "BuiltInErrors.NetworkError.decodingFailure",
            defaultValue: "The data received from the server could not be processed. Please try again.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
