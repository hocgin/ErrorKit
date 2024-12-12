import Foundation

/// Represents errors related to failed or invalid operations.
public enum OperationError: Throwable {
   /// The operation could not start due to a dependency failure.
   /// - Parameter dependency: A description of the failed dependency.
   case dependencyFailed(dependency: String)

   /// The operation was canceled before completion.
   case canceled

   /// The operation failed with an unknown reason.
   case unknownFailure(description: String)

   /// Generic error message if the existing cases don't provide the required details.
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .dependencyFailed(let dependency):
         return String(
            localized: "BuiltInErrors.OperationError.dependencyFailed",
            defaultValue: "The operation could not be completed due to a failed dependency: \(dependency).",
            bundle: .module
         )
      case .canceled:
         return String(
            localized: "BuiltInErrors.OperationError.canceled",
            defaultValue: "The operation was canceled. Please try again if necessary.",
            bundle: .module
         )
      case .unknownFailure(let description):
         return String(
            localized: "BuiltInErrors.OperationError.unknownFailure",
            defaultValue: "The operation failed due to an unknown reason: \(description). Please try again or contact support.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
