import Foundation

/// Represents errors related to missing or denied permissions.
public enum PermissionError: Throwable {
   /// The user denied the required permission.
   /// - Parameter permission: The type of permission that was denied.
   case denied(permission: String)

   /// The app lacks a required permission and the user cannot grant it.
   /// - Parameter permission: The type of permission required.
   case restricted(permission: String)

   /// The app lacks a required permission, and it is unknown whether the user can grant it.
   case notDetermined(permission: String)

   /// Generic error message if the existing cases don't provide the required details.
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .denied(let permission):
         return String(
            localized: "BuiltInErrors.PermissionError.denied",
            defaultValue: "The \(permission) permission was denied. Please enable it in Settings to continue.",
            bundle: .module
         )
      case .restricted(let permission):
         return String(
            localized: "BuiltInErrors.PermissionError.restricted",
            defaultValue: "The \(permission) permission is restricted. This may be due to parental controls or other system restrictions.",
            bundle: .module
         )
      case .notDetermined(let permission):
         return String(
            localized: "BuiltInErrors.PermissionError.notDetermined",
            defaultValue: "The \(permission) permission has not been determined. Please try again or check your Settings.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
