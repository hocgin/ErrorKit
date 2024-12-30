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
      return self.chainDescription(for: error, isRoot: true)
   }

   private static func chainDescription(for error: Error, isRoot: Bool = false, prefix: String = "") -> String {
      // Get type information
      let typeName = String(describing: type(of: error))
      var output = ""

      // Handle root level format
      if isRoot {
         if isLeafNode(error) {
            output += "─ " + typeNameWithKind(error)
         } else {
            output += typeName  // No prefix for nested error chains
         }
      } else {
         // For non-root nodes, we need to check if this is a 'caught' case or a regular error case
         if let catchingError = error as? any Catching,
            Mirror(reflecting: catchingError).children.first?.label == "caught" {
            // Just show the type name for catching errors
            output += prefix + "└─ \(typeName)"
         } else {
            // For regular error cases, show the full type name and case
            let caseDescription = String(describing: error)
            let errorTypeName = String(describing: type(of: error))
            output += prefix + "└─ \(errorTypeName).\(caseDescription)"
         }
      }

      // If this is a Catching error, check for nested errors
      if let catchingError = error as? any Catching,
         let mirror = Mirror(reflecting: catchingError).children.first,
         mirror.label == "caught" {
         // Recursively build trace for nested error
         let nextPrefix = isRoot ? "   " : prefix + "   "
         output += "\n" + self.chainDescription(
            for: mirror.value as! Error,
            prefix: nextPrefix
         )
      } else {
         // For leaf nodes or non-Catching errors, add userFriendlyMessage
         let message = ErrorKit.userFriendlyMessage(for: error)
         output += "\n" + prefix + "  └─ userFriendlyMessage: \"\(message)\""
      }

      return output
   }

   private static func isLeafNode(_ error: Error) -> Bool {
      // Check if it's not a Catching error or if it doesn't have a caught error
      if let catchingError = error as? any Catching,
         let mirror = Mirror(reflecting: catchingError).children.first,
         mirror.label == "caught" {
         return false
      }
      return true
   }

   private static func typeNameWithKind(_ error: Error) -> String {
      let mirror = Mirror(reflecting: error)
      if mirror.displayStyle == .struct {
         return "\(String(describing: type(of: error))) [Struct]"
      } else if mirror.displayStyle == .class {
         return "\(String(describing: type(of: error))) [Class]"
      }
      return String(describing: type(of: error))
   }
}
