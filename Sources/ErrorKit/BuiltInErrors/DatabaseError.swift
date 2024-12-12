import Foundation

/// Represents errors that occur during database operations.
public enum DatabaseError: Throwable {
   /// The database connection failed.
   case connectionFailed

   /// The database query failed to execute.
   /// - Parameters:
   ///   - context: A description of the operation or entity being queried.
   case operationFailed(context: String)

   /// A requested record was not found in the database.
   /// - Parameters:
   ///   - entity: The name of the entity or record type.
   ///   - identifier: A unique identifier for the missing entity.
   case recordNotFound(entity: String, identifier: String?)

   /// Generic error message if the existing cases don't provide the required details.
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .connectionFailed:
         return String(
            localized: "BuiltInErrors.DatabaseError.connectionFailed",
            defaultValue: "Failed to connect to the database. Please try again later.",
            bundle: .module
         )
      case .operationFailed(let context):
         return String(
            localized: "BuiltInErrors.DatabaseError.operationFailed",
            defaultValue: "An error occurred while performing the operation: \(context). Please try again.",
            bundle: .module
         )
      case .recordNotFound(let entity, let identifier):
         let idMessage = identifier.map { " Identifier: \($0)." } ?? ""
         return String(
            localized: "BuiltInErrors.DatabaseError.recordNotFound",
            defaultValue: "The \(entity) record could not be found.\(idMessage) Please check and try again.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
