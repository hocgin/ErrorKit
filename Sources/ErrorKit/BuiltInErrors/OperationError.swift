import Foundation

/// Represents errors related to failed or invalid operations.
///
/// # Examples of Use
///
/// ## Handling Operation Dependencies
/// ```swift
/// struct DataProcessingPipeline {
///     func runComplexOperation() throws(OperationError) {
///         guard checkDependencies() else {
///             throw .dependencyFailed(dependency: "Cache Initialization")
///         }
///         // Operation processing logic
///     }
/// }
/// ```
///
/// ## Managing Cancelable Operations
/// ```swift
/// struct BackgroundTask {
///     func performLongRunningTask() throws(OperationError) {
///         guard !isCancellationRequested() else {
///             throw .canceled
///         }
///         // Long-running task logic
///     }
/// }
/// ```
public enum OperationError: Throwable {
   /// The operation could not start due to a dependency failure.
   ///
   /// # Example
   /// ```swift
   /// struct DataSynchronizer {
   ///     func synchronize() throws(OperationError) {
   ///         guard isNetworkReady() else {
   ///             throw .dependencyFailed(dependency: "Network Connection")
   ///         }
   ///         // Synchronization logic
   ///     }
   /// }
   /// ```
   /// - Parameter dependency: A description of the failed dependency.
   case dependencyFailed(dependency: String)

   /// The operation was canceled before completion.
   ///
   /// # Example
   /// ```swift
   /// struct ImageProcessor {
   ///     func processImage() throws(OperationError) {
   ///         guard !userRequestedCancel else {
   ///             throw .canceled
   ///         }
   ///         // Image processing logic
   ///     }
   /// }
   /// ```
   case canceled

   /// Generic error message if the existing cases don't provide the required details.
   ///
   /// # Example
   /// ```swift
   /// struct GenericErrorManager {
   ///     func handleSpecialCase() throws(OperationError) {
   ///         guard !isHandledCase() else {
   ///             throw .generic(userFriendlyMessage: "A unique operation error occurred")
   ///         }
   ///         // Special case handling
   ///     }
   /// }
   /// ```
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .dependencyFailed(let dependency):
         return String(
            localized: "BuiltInErrors.OperationError.dependencyFailed",
            defaultValue: "The operation could not be started because a required component failed to initialize: \(dependency). Please restart the application or contact support.",
            bundle: .module
         )
      case .canceled:
         return String(
            localized: "BuiltInErrors.OperationError.canceled",
            defaultValue: "The operation was canceled at your request. You can retry the action if needed.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
