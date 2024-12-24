import Foundation

/// Represents errors that can occur during network operations.
///
/// # Examples of Use
///
/// ## Handling Network Connectivity
/// ```swift
/// struct NetworkService {
///     func fetchData() throws(NetworkError) -> Data {
///         guard isNetworkReachable() else {
///             throw .noInternet
///         }
///         // Network request logic
///     }
/// }
/// ```
///
/// ## Managing API Requests
/// ```swift
/// struct APIClient {
///     func makeRequest<T: Decodable>(to endpoint: URL) throws(NetworkError) -> T {
///         guard let response = performRequest(endpoint) else {
///             throw .timeout
///         }
///
///         guard response.statusCode == 200 else {
///             throw .badRequest(
///                 code: response.statusCode,
///                 message: response.errorMessage
///             )
///         }
///
///         guard let decodedData = try? JSONDecoder().decode(T.self, from: response.data) else {
///             throw .decodingFailure
///         }
///
///         return decodedData
///     }
/// }
/// ```
public enum NetworkError: Throwable, Catching {
   /// No internet connection is available.
   ///
   /// # Example
   /// ```swift
   /// struct OfflineContentManager {
   ///     func syncContent() throws(NetworkError) {
   ///         guard isNetworkAvailable() else {
   ///             throw .noInternet
   ///         }
   ///         // Synchronization logic
   ///     }
   /// }
   /// ```
   /// - Note: This error may occur if the device is in airplane mode or lacks network connectivity.
   case noInternet

   /// The request timed out before completion.
   ///
   /// # Example
   /// ```swift
   /// struct ImageDownloader {
   ///     func download(from url: URL) throws(NetworkError) -> Image {
   ///         guard let image = performDownloadWithTimeout() else {
   ///             throw .timeout
   ///         }
   ///         return image
   ///     }
   /// }
   /// ```
   case timeout

   /// The server responded with a bad request error.
   ///
   /// # Example
   /// ```swift
   /// struct UserProfileService {
   ///     func updateProfile(_ profile: UserProfile) throws(NetworkError) {
   ///         let response = sendUpdateRequest(profile)
   ///         guard response.isSuccess else {
   ///             throw .badRequest(
   ///                 code: response.statusCode,
   ///                 message: response.errorMessage
   ///             )
   ///         }
   ///         // Update success logic
   ///     }
   /// }
   /// ```
   /// - Parameters:
   ///   - code: The exact HTTP status code returned by the server.
   ///   - message: An error message provided by the server in the body.
   case badRequest(code: Int, message: String)

   /// The server responded with a general server-side error.
   ///
   /// # Example
   /// ```swift
   /// struct PaymentService {
   ///     func processPayment(_ payment: Payment) throws(NetworkError) {
   ///         let response = submitPayment(payment)
   ///         guard response.isSuccessful else {
   ///             throw .serverError(
   ///                 code: response.statusCode,
   ///                 message: response.errorMessage
   ///             )
   ///         }
   ///         // Payment processing logic
   ///     }
   /// }
   /// ```
   /// - Parameters:
   ///   - code: The HTTP status code returned by the server.
   ///   - message: An optional error message provided by the server.
   case serverError(code: Int, message: String?)

   /// The response could not be decoded or parsed.
   ///
   /// # Example
   /// ```swift
   /// struct DataTransformer {
   ///     func parseResponse<T: Decodable>(_ data: Data) throws(NetworkError) -> T {
   ///         guard let parsed = try? JSONDecoder().decode(T.self, from: data) else {
   ///             throw .decodingFailure
   ///         }
   ///         return parsed
   ///     }
   /// }
   /// ```
   case decodingFailure

   /// Generic error message if the existing cases don't provide the required details.
   ///
   /// # Example
   /// ```swift
   /// struct UnexpectedErrorHandler {
   ///     func handle(_ error: Error) throws(NetworkError) {
   ///         guard !isHandledError(error) else {
   ///             throw .generic(userFriendlyMessage: "An unexpected network error occurred")
   ///         }
   ///         // Error handling logic
   ///     }
   /// }
   /// ```
   case generic(userFriendlyMessage: String)

   /// An error that occurred during a network operation, wrapped into this error type using the ``catch(_:)`` function.
   /// This could include URLSession errors, SSL/TLS errors, or any other errors encountered during network communication.
   ///
   /// # Example
   /// ```swift
   /// struct APIClient {
   ///     func fetchUserProfile(id: String) throws(NetworkError) {
   ///         // Regular error for no connectivity
   ///         guard isNetworkReachable else {
   ///             throw NetworkError.noInternet
   ///         }
   ///
   ///         // Automatically wrap URLSession and decoding errors
   ///         let profile = try NetworkError.catch {
   ///             let (data, response) = try await URLSession.shared.data(from: userProfileURL)
   ///             return try JSONDecoder().decode(UserProfile.self, from: data)
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
   ///   - error: The original error that occurred during the network operation.
   case caught(Error)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .noInternet:
         return String(
            localized: "BuiltInErrors.NetworkError.noInternet",
            defaultValue: "Unable to connect to the internet. Please check your network settings and try again.",
            bundle: .module
         )
      case .timeout:
         return String(
            localized: "BuiltInErrors.NetworkError.timeout",
            defaultValue: "The network request took too long to complete. Please check your connection and try again.",
            bundle: .module
         )
      case .badRequest(let code, let message):
         return String(
            localized: "BuiltInErrors.NetworkError.badRequest",
            defaultValue: "There was an issue with the request (Code: \(code)). \(message). Please review and retry.",
            bundle: .module
         )
      case .serverError(let code, let message):
         let defaultMessage = String(
            localized: "BuiltInErrors.NetworkError.serverError",
            defaultValue: "The server encountered an error (Code: \(code)). ",
            bundle: .module
         )
         if let message = message {
            return defaultMessage + message
         } else {
            return defaultMessage + "Please try again later."
         }
      case .decodingFailure:
         return String(
            localized: "BuiltInErrors.NetworkError.decodingFailure",
            defaultValue: "Unable to process the server's response. Please try again or contact support if the issue persists.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      case .caught(let error):
         return error.localizedDescription
      }
   }
}
