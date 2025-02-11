import Foundation

/// Represents errors that occur during database operations.
///
/// # Examples of Use
///
/// ## Handling Database Connections
/// ```swift
/// struct DatabaseConnection {
///     func connect() throws(DatabaseError) {
///         guard let socket = openNetworkSocket() else {
///             throw .connectionFailed
///         }
///         // Successful connection logic
///     }
/// }
/// ```
///
/// ## Managing Record Operations
/// ```swift
/// struct UserRepository {
///     func findUser(byId id: String) throws(DatabaseError) -> User {
///         guard let user = database.findUser(id: id) else {
///             throw .recordNotFound(entity: "User", identifier: id)
///         }
///         return user
///     }
///
///     func updateUser(_ user: User) throws(DatabaseError) {
///         guard hasValidPermissions(for: user) else {
///             throw .operationFailed(context: "Updating user profile")
///         }
///         // Update logic
///     }
/// }
/// ```
public enum DatabaseError: Throwable, Catching {
   /// The database connection failed.
   ///
   /// # Example
   /// ```swift
   /// struct AuthenticationService {
   ///     func authenticate() throws(DatabaseError) {
   ///         guard let connection = attemptDatabaseConnection() else {
   ///             throw .connectionFailed
   ///         }
   ///         // Proceed with authentication
   ///     }
   /// }
   /// ```
   case connectionFailed

   /// The database query failed to execute.
   ///
   /// # Example
   /// ```swift
   /// struct AnalyticsRepository {
   ///     func generateReport(for period: DateInterval) throws(DatabaseError) -> Report {
   ///         guard period.duration <= maximumReportPeriod else {
   ///             throw .operationFailed(context: "Generating analytics report")
   ///         }
   ///         // Report generation logic
   ///     }
   /// }
   /// ```
   /// - Parameters:
   ///   - context: A description of the operation or entity being queried.
   case operationFailed(context: String)

   /// A requested record was not found in the database.
   ///
   /// # Example
   /// ```swift
   /// struct ProductInventory {
   ///     func fetchProduct(sku: String) throws(DatabaseError) -> Product {
   ///         guard let product = database.findProduct(bySKU: sku) else {
   ///             throw .recordNotFound(entity: "Product", identifier: sku)
   ///         }
   ///         return product
   ///     }
   /// }
   /// ```
   /// - Parameters:
   ///   - entity: The name of the entity or record type.
   ///   - identifier: A unique identifier for the missing entity.
   case recordNotFound(entity: String, identifier: String?)

   /// Generic error message if the existing cases don't provide the required details.
   ///
   /// # Example
   /// ```swift
   /// struct DataMigrationService {
   ///     func migrate() throws(DatabaseError) {
   ///         guard canPerformMigration() else {
   ///             throw .generic(userFriendlyMessage: "Migration cannot be performed")
   ///         }
   ///         // Migration logic
   ///     }
   /// }
   /// ```
   case generic(userFriendlyMessage: String)

   /// Represents a child error (either from your own error types or unknown system errors) that was wrapped into this error type.
   /// This case is used internally by the ``catch(_:)`` function to store any errors thrown by the wrapped code.
   ///
   /// # Example
   /// ```swift
   /// struct UserRepository {
   ///     func fetchUserDetails(id: String) throws(DatabaseError) {
   ///         // Check if user exists - simple case with explicit error
   ///         guard let user = database.findUser(id: id) else {
   ///             throw DatabaseError.recordNotFound(entity: "User", identifier: id)
   ///         }
   ///
   ///         // Any errors from parsing or file access are automatically wrapped
   ///         let preferences = try DatabaseError.catch {
   ///             let prefsData = try fileManager.contents(ofFile: user.preferencesPath)
   ///             return try JSONDecoder().decode(UserPreferences.self, from: prefsData)
   ///         }
   ///
   ///         // Use the loaded preferences
   ///         user.applyPreferences(preferences)
   ///     }
   /// }
   /// ```
   ///
   /// The `caught` case stores the original error while maintaining type safety through typed throws.
   /// Instead of manually catching and wrapping unknown errors, use the ``catch(_:)`` function
   /// which automatically wraps any thrown errors into this case.
   ///
   /// - Parameters:
   ///   - error: The original error that was wrapped into this error type.
   case caught(Error)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .connectionFailed:
         return String(
            localized: "BuiltInErrors.DatabaseError.connectionFailed",
            defaultValue: "Unable to establish a connection to the database. Check your network settings and try again.",
            bundle: .module
         )
      case .operationFailed(let context):
         return String(
            localized: "BuiltInErrors.DatabaseError.operationFailed",
            defaultValue: "The database operation for \(context) could not be completed. Please retry the action.",
            bundle: .module
         )
      case .recordNotFound(let entity, let identifier):
         if let identifier {
            return String(
               localized: "BuiltInErrors.DatabaseError.recordNotFoundWithID",
               defaultValue: "The \(entity) record with ID \(identifier) was not found in the database. Verify the details and try again.",
               bundle: .module
            )
         } else {
            return String(
               localized: "BuiltInErrors.DatabaseError.recordNotFound",
               defaultValue: "The \(entity) record was not found in the database. Verify the details and try again.",
               bundle: .module
            )
         }
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      case .caught(let error):
         return ErrorKit.userFriendlyMessage(for: error)
      }
   }
}
