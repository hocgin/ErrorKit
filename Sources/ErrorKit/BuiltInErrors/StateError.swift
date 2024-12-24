import Foundation

/// Represents errors caused by invalid or unexpected states.
///
/// # Examples of Use
///
/// ## Managing State Transitions
/// ```swift
/// struct OrderProcessor {
///     func processOrder(_ order: Order) throws(StateError) {
///         guard order.status == .pending else {
///             throw .invalidState(description: "Order must be in pending state")
///         }
///         // Order processing logic
///     }
/// }
/// ```
///
/// ## Handling Finalized States
/// ```swift
/// struct DocumentManager {
///     func updateDocument(_ doc: Document) throws(StateError) {
///         guard !doc.isFinalized else {
///             throw .alreadyFinalized
///         }
///         // Document update logic
///     }
/// }
/// ```
public enum StateError: Throwable, Catching {
   /// The required state was not met to proceed with the operation.
   ///
   /// # Example
   /// ```swift
   /// struct PaymentProcessor {
   ///     func refundPayment(_ payment: Payment) throws(StateError) {
   ///         guard payment.status == .completed else {
   ///             throw .invalidState(description: "Payment must be completed")
   ///         }
   ///         // Refund processing logic
   ///     }
   /// }
   /// ```
   case invalidState(description: String)

   /// The operation cannot proceed because the state has already been finalized.
   ///
   /// # Example
   /// ```swift
   /// struct ContractManager {
   ///     func modifyContract(_ contract: Contract) throws(StateError) {
   ///         guard !contract.isFinalized else {
   ///             throw .alreadyFinalized
   ///         }
   ///         // Contract modification logic
   ///     }
   /// }
   /// ```
   case alreadyFinalized

   /// A required precondition for the operation was not met.
   ///
   /// # Example
   /// ```swift
   /// struct GameEngine {
   ///     func startNewLevel() throws(StateError) {
   ///         guard player.hasCompletedTutorial else {
   ///             throw .preconditionFailed(description: "Tutorial must be completed")
   ///         }
   ///         // Level initialization logic
   ///     }
   /// }
   /// ```
   case preconditionFailed(description: String)

   /// Generic error message if the existing cases don't provide the required details.
   ///
   /// # Example
   /// ```swift
   /// struct StateHandler {
   ///     func handleUnexpectedState() throws(StateError) {
   ///         guard isStateValid() else {
   ///             throw .generic(userFriendlyMessage: "System is in an unexpected state")
   ///         }
   ///         // State handling logic
   ///     }
   /// }
   /// ```
   case generic(userFriendlyMessage: String)

   /// An error that occurred due to state management issues, wrapped into this error type using the ``catch(_:)`` function.
   /// This could include state transition errors, validation errors, or any other errors encountered during state-dependent operations.
   ///
   /// # Example
   /// ```swift
   /// struct OrderProcessor {
   ///     func finalizeOrder(_ order: Order) throws(StateError) {
   ///         // Regular error for invalid state
   ///         guard order.status == .verified else {
   ///             throw StateError.invalidState(description: "Order must be verified")
   ///         }
   ///
   ///         // Automatically wrap payment and inventory state errors
   ///         try StateError.catch {
   ///             let paymentResult = try paymentGateway.processPayment(order.payment)
   ///             try inventoryManager.reserveItems(order.items)
   ///             try order.moveToState(.finalized)
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
   ///   - error: The original error that occurred during the state-dependent operation.
   case caught(Error)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .invalidState(let description):
         return String(
            localized: "BuiltInErrors.StateError.invalidState",
            defaultValue: "The current state prevents this action: \(description). Please ensure all requirements are met and try again.",
            bundle: .module
         )
      case .alreadyFinalized:
         return String(
            localized: "BuiltInErrors.StateError.alreadyFinalized",
            defaultValue: "This item has already been finalized and cannot be modified. Please create a new version if changes are needed.",
            bundle: .module
         )
      case .preconditionFailed(let description):
         return String(
            localized: "BuiltInErrors.StateError.preconditionFailed",
            defaultValue: "A required condition was not met: \(description). Please complete all prerequisites before proceeding.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      case .caught(let error):
         return error.localizedDescription
      }
   }
}
