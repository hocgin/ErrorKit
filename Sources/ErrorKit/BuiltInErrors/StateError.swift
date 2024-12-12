import Foundation

/// Represents errors caused by invalid or unexpected states.
public enum StateError: Throwable {
   /// The required state was not met to proceed with the operation.
   case invalidState(description: String)

   /// The operation cannot proceed because the state has already been finalized.
   case alreadyFinalized

   /// A required precondition for the operation was not met.
   case preconditionFailed(description: String)

   /// Generic error message if the existing cases don't provide the required details.
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .invalidState(let description):
         return String(
            localized: "BuiltInErrors.StateError.invalidState",
            defaultValue: "The operation cannot proceed due to an invalid state: \(description).",
            bundle: .module
         )
      case .alreadyFinalized:
         return String(
            localized: "BuiltInErrors.StateError.alreadyFinalized",
            defaultValue: "The operation cannot be performed because the state is already finalized.",
            bundle: .module
         )
      case .preconditionFailed(let description):
         return String(
            localized: "BuiltInErrors.StateError.preconditionFailed",
            defaultValue: "A required condition was not met: \(description). Please review and try again.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
