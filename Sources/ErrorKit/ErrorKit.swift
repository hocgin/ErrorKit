import Foundation

public enum ErrorKit {
   /// Provides enhanced, user-friendly, localized error descriptions for a wide range of system errors.
   ///
   /// This function analyzes the given `Error` and returns a clearer, more helpful message than the default system-provided description.
   /// All descriptions are localized, ensuring that users receive messages in their preferred language where available.
   ///
   /// The list of user-friendly messages is maintained and regularly improved by the developer community. Contributions are welcome—if you find bugs or encounter new errors, feel free to submit a pull request (PR) for review.
   ///
   /// Errors from various domains, such as `Foundation`, `CoreData`, `MapKit`, and more, are supported. As the project evolves, additional domains may be included to ensure comprehensive coverage.
   ///
   /// - Parameter error: The `Error` instance for which a user-friendly message is needed.
   /// - Returns: A `String` containing an enhanced, localized, user-readable error message.
   ///
   /// ## Usage Example:
   /// ```swift
   /// do {
   ///     // Example network request
   ///     let url = URL(string: "https://example.com")!
   ///     let _ = try Data(contentsOf: url)
   /// } catch {
   ///     print(ErrorKit.userFriendlyMessage(for: error))
   ///     // Output: "You are not connected to the Internet. Please check your connection." (if applicable)
   /// }
   /// ```
   public static func userFriendlyMessage(for error: Error) -> String {
      // Any types conforming to `Throwable` are assumed to already have a good description
      if let throwable = error as? Throwable {
         return throwable.userFriendlyMessage
      }

      if let foundationDescription = Self.userFriendlyFoundationMessage(for: error) {
         return foundationDescription
      }

      if let coreDataDescription = Self.userFriendlyCoreDataMessage(for: error) {
         return coreDataDescription
      }

      if let mapKitDescription = Self.userFriendlyMapKitMessage(for: error) {
         return mapKitDescription
      }

      // LocalizedError: The recommended error type to conform to in Swift by default.
      if let localizedError = error as? LocalizedError {
         return [
            localizedError.errorDescription,
            localizedError.failureReason,
            localizedError.recoverySuggestion,
         ].compactMap(\.self).joined(separator: " ")
      }

      // Default fallback (adds domain & code at least)
      let nsError = error as NSError
      return "[\(nsError.domain): \(nsError.code)] \(nsError.localizedDescription)"
   }

   // TODO: add documentation
   public static func errorChainDescription(for error: Error) -> String {
      return Self.chainDescription(for: error, indent: "", enclosingType: type(of: error))
   }

   private static func chainDescription(for error: Error, indent: String, enclosingType: Any.Type?) -> String {
      let mirror = Mirror(reflecting: error)

      // Helper function to format the type name with optional metadata
      func typeDescription(_ error: Error, enclosingType: Any.Type?) -> String {
         let typeName = String(describing: type(of: error))

         // For structs and classes (non-enums), append [Struct] or [Class]
         if mirror.displayStyle != .enum {
            let isClass = Swift.type(of: error) is AnyClass
            return "\(typeName) [\(isClass ? "Class" : "Struct")]"
         } else {
            // For enums, include the full case description with type name
            if let enclosingType {
               return "\(enclosingType).\(error)"
            } else {
               return String(describing: error)
            }
         }
      }

      // Check if this is a nested error (conforms to Catching and has a caught case)
      if let caughtError = mirror.children.first(where: { $0.label == "caught" })?.value as? Error {
         let currentErrorType = type(of: error)
         let nextIndent = indent + "   "
         return """
            \(currentErrorType)
            \(indent)└─ \(Self.chainDescription(for: caughtError, indent: nextIndent, enclosingType: type(of: caughtError)))
            """
      } else {
         // This is a leaf node
         return """
            \(typeDescription(error, enclosingType: enclosingType))
            \(indent)└─ userFriendlyMessage: \"\(Self.userFriendlyMessage(for: error))\"
            """
      }
   }
}
