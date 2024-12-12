import Foundation

/// Represents errors that occur during file operations.
public enum FileError: Throwable {
   /// The file could not be found.
   case fileNotFound(fileName: String)

   /// There was an issue reading the file.
   case readFailed(fileName: String)

   /// There was an issue writing to the file.
   case writeFailed(fileName: String)

   /// Generic error message if the existing cases don't provide the required details.
   case generic(userFriendlyMessage: String)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .fileNotFound(let fileName):
         return String(
            localized: "BuiltInErrors.FileError.fileNotFound",
            defaultValue: "The file \(fileName) could not be found. Please check the file path.",
            bundle: .module
         )
      case .readFailed(let fileName):
         return String(
            localized: "BuiltInErrors.FileError.readError",
            defaultValue: "There was an issue reading the file \(fileName). Please try again.",
            bundle: .module
         )
      case .writeFailed(let fileName):
         return String(
            localized: "BuiltInErrors.FileError.writeError",
            defaultValue: "There was an issue writing to the file \(fileName). Please try again.",
            bundle: .module
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      }
   }
}
