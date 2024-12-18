import Foundation

/// Represents errors related to missing or denied permissions.
///
/// # Examples of Use
///
/// ## Handling Permission Checks
/// ```swift
/// struct LocationService {
///     func requestLocation() throws(PermissionError) {
///         switch checkLocationPermission() {
///         case .denied:
///             throw .denied(permission: "Location")
///         case .restricted:
///             throw .restricted(permission: "Location")
///         case .notDetermined:
///             throw .notDetermined(permission: "Location")
///         case .authorized:
///             // Proceed with location request
///         }
///     }
/// }
/// ```
///
/// ## Managing Permission Workflows
/// ```swift
/// struct CameraAccessManager {
///     func verifyAndRequestCameraAccess() throws(PermissionError) {
///         guard canRequestCameraPermission() else {
///             throw .restricted(permission: "Camera")
///         }
///         // Permission request logic
///     }
/// }
/// ```
public enum PermissionError: Throwable {
   /// The user denied the required permission.
   ///
   /// # Example
   /// ```swift
   /// struct PhotoLibraryManager {
   ///     func accessPhotoLibrary() throws(PermissionError) {
   ///         guard isPhotoLibraryAccessAllowed() else {
   ///             throw .denied(permission: "Photo Library")
   ///         }
   ///         // Photo library access logic
   ///     }
   /// }
   /// ```
   /// - Parameter permission: The type of permission that was denied.
   case denied(permission: String)

   /// The app lacks a required permission and the user cannot grant it.
   ///
   /// # Example
   /// ```swift
   /// struct HealthDataService {
   ///     func accessHealthData() throws(PermissionError) {
   ///         guard canRequestHealthPermission() else {
   ///             throw .restricted(permission: "Health Data")
   ///         }
   ///         // Health data access logic
   ///     }
   /// }
   /// ```
   /// - Parameter permission: The type of permission required.
   case restricted(permission: String)

   /// The app lacks a required permission, and it is unknown whether the user can grant it.
   ///
   /// # Example
   /// ```swift
   /// struct NotificationManager {
   ///     func setupNotifications() throws(PermissionError) {
   ///         guard isNotificationPermissionStatusKnown() else {
   ///             throw .notDetermined(permission: "Notifications")
   ///         }
   ///         // Notification setup logic
   ///     }
   /// }
   /// ```
   case notDetermined(permission: String)

   /// Generic error message if the existing cases don't provide the required details.
   ///
   /// # Example
   /// ```swift
   /// struct UnexpectedPermissionHandler {
   ///     func handleSpecialCase() throws(PermissionError) {
   ///         guard !isHandledCase() else {
   ///             throw .generic(userFriendlyMessage: "A unique permission error occurred")
   ///         }
   ///         // Special case handling
   ///     }
   /// }
   /// ```
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .denied(let permission):
         return String(
            localized: "BuiltInErrors.PermissionError.denied",
            defaultValue: "Access to \(permission) was declined. To use this feature, please enable the permission in your device Settings.",
            bundle: .module
         )
      case .restricted(let permission):
         return String(
            localized: "BuiltInErrors.PermissionError.restricted",
            defaultValue: "Access to \(permission) is currently restricted. This may be due to system settings or parental controls.",
            bundle: .module
         )
      case .notDetermined(let permission):
         return String(
            localized: "BuiltInErrors.PermissionError.notDetermined",
            defaultValue: "Permission for \(permission) has not been confirmed. Please review and grant access in your device Settings.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
