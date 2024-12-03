import Foundation

public enum ErrorKit {
   /// Provides improved and more helpful error messages for a community-maintained list of common system errors.
   public static func enhancedDescription(for error: Error) -> String {
      // Any types conforming to `Throwable` are assumed to already have a good description
      if let throwable = error as? Throwable {
         return throwable.localizedDescription
      }

      if let foundationDescription = Self.enhancedFoundationDescription(for: error) {
         return foundationDescription
      }

      if let coreDataDescription = Self.enhancedCoreDataDescription(for: error) {
         return coreDataDescription
      }

      if let mapKitDescription = Self.enhancedMapKitDescription(for: error) {
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
}
