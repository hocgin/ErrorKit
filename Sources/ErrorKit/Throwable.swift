import Foundation

/// A protocol that makes error handling in Swift more intuitive by requiring a user-friendly `localizedDescription` property.
///
/// `Throwable` extends `LocalizedError` and simplifies the process of defining error messages,
/// ensuring that developers can provide meaningful feedback for errors without the confusion associated with Swift's native `Error` and `LocalizedError` types.
///
/// ### Key Features:
/// - Requires a `localizedDescription`, making it easier to provide custom error messages.
/// - Offers a default implementation for `errorDescription`, ensuring smooth integration with `LocalizedError`.
/// - Supports `RawRepresentable` enums with `String` as `RawValue` to minimize boilerplate.
///
/// ### Why Use `Throwable`?
/// - **Simplified API**: Unlike `LocalizedError`, `Throwable` focuses on a single requirement: `localizedDescription`.
/// - **Intuitive Naming**: The name aligns with Swift's `throw` keyword and other common `-able` protocols like `Codable`.
/// - **Readable Error Handling**: Provides concise, human-readable error descriptions.
///
/// ### Usage Example:
///
/// #### 1. Custom Error with Manual `localizedDescription`:
/// ```swift
/// enum NetworkError: Throwable {
///     case noConnectionToServer
///     case parsingFailed
///
///     var localizedDescription: String {
///         switch self {
///         case .noConnectionToServer: "Unable to connect to the server."
///         case .parsingFailed: "Data parsing failed."
///         }
///     }
/// }
/// ```
///
/// #### 2. Custom Error Using `RawRepresentable` for Minimal Boilerplate:
/// ```swift
/// enum NetworkError: String, Throwable {
///     case noConnectionToServer = "Unable to connect to the server."
///     case parsingFailed = "Data parsing failed."
/// }
/// ```
///
/// #### 3. Throwing and Catching Errors:
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         Button("Throw Random NetworkError") {
///             do {
///                 throw NetworkError.allCases.randomElement()!
///             } catch {
///                 print("Caught error with message: \(error.localizedDescription)")
///             }
///         }
///     }
/// }
/// ```
/// Output:
/// ```
/// Caught error with message: Unable to connect to the server.
/// ```
///
public protocol Throwable: LocalizedError {
   /// A human-readable error message describing the error.
   var localizedDescription: String { get }
}

// MARK: - Default Implementations

/// Provides a default implementation for `Throwable` when the conforming type is a `RawRepresentable` with a `String` raw value.
///
/// This allows enums with `String` raw values to automatically use the raw value as the error's `localizedDescription`.
extension Throwable where Self: RawRepresentable, RawValue == String {
   public var localizedDescription: String {
      self.rawValue
   }
}

/// Provides a default implementation for `errorDescription` required by `LocalizedError`, ensuring it returns the value of `localizedDescription`.
extension Throwable {
   public var errorDescription: String? {
      self.localizedDescription
   }
}
