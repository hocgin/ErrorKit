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
public enum OperationError: Throwable, Catching {
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

   /// An error that occurred during an operation execution, wrapped into this error type using the ``catch(_:)`` function.
   /// This could include task cancellation errors, operation queue errors, or any other errors encountered during complex operations.
   ///
   /// # Example
   /// ```swift
   /// struct DataProcessor {
   ///     func processLargeDataset(_ dataset: Dataset) throws(OperationError) {
   ///         // Regular error for operation prerequisites
   ///         guard meetsMemoryRequirements(dataset) else {
   ///             throw OperationError.dependencyFailed(dependency: "Memory Requirements")
   ///         }
   ///
   ///         // Automatically wrap operation and processing errors
   ///         let result = try OperationError.catch {
   ///             let operation = try ProcessingOperation(dataset)
   ///             try operation.validateInputs()
   ///             return try operation.execute()
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
   ///   - error: The original error that occurred during the operation.
   case caught(Error)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .dependencyFailed(let dependency):
         return String.localized(
            key: "BuiltInErrors.OperationError.dependencyFailed",
            defaultValue:
               "The operation could not be started because a required component failed to initialize: \(dependency). Please restart the application or contact support."
         )
      case .canceled:
         return String.localized(
            key: "BuiltInErrors.OperationError.canceled",
            defaultValue: "The operation was canceled at your request. You can retry the action if needed."
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      case .caught(let error):
         return ErrorKit.userFriendlyMessage(for: error)
      }
   }
}
