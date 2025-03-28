import Foundation

/// Represents errors that occur during file operations.
///
/// # Examples of Use
///
/// ## Handling File Retrieval
/// ```swift
/// struct DocumentManager {
///     func loadDocument(named name: String) throws(FileError) -> Document {
///         guard let fileURL = findFile(named: name) else {
///             throw .fileNotFound(fileName: name)
///         }
///         // Document loading logic
///     }
/// }
/// ```
///
/// ## Managing File Operations
/// ```swift
/// struct FileProcessor {
///     func processFile(at path: String) throws(FileError) {
///         guard canWrite(to: path) else {
///             throw .writeFailed(fileName: path)
///         }
///         // File processing logic
///     }
///
///     func readConfiguration() throws(FileError) -> Configuration {
///         guard let data = attemptFileRead() else {
///             throw .readFailed(fileName: "config.json")
///         }
///         // Configuration parsing logic
///     }
/// }
/// ```
public enum FileError: Throwable, Catching {
   /// The file could not be found.
   ///
   /// # Example
   /// ```swift
   /// struct AssetManager {
   ///     func loadImage(named name: String) throws(FileError) -> Image {
   ///         guard let imagePath = searchForImage(name) else {
   ///             throw .fileNotFound(fileName: name)
   ///         }
   ///         // Image loading logic
   ///     }
   /// }
   /// ```
   case fileNotFound(fileName: String)

   /// There was an issue reading the file.
   ///
   /// # Example
   /// ```swift
   /// struct LogReader {
   ///     func readLatestLog() throws(FileError) -> String {
   ///         guard let logContents = attemptFileRead() else {
   ///             throw .readFailed(fileName: "application.log")
   ///         }
   ///         return logContents
   ///     }
   /// }
   /// ```
   case readFailed(fileName: String)

   /// There was an issue writing to the file.
   ///
   /// # Example
   /// ```swift
   /// struct DataBackup {
   ///     func backup(data: Data) throws(FileError) {
   ///         guard canWriteToBackupLocation() else {
   ///             throw .writeFailed(fileName: "backup.dat")
   ///         }
   ///         // Backup writing logic
   ///     }
   /// }
   /// ```
   case writeFailed(fileName: String)

   /// Generic error message if the existing cases don't provide the required details.
   ///
   /// # Example
   /// ```swift
   /// struct FileIntegrityChecker {
   ///     func validateFile() throws(FileError) {
   ///         guard passes(integrityCheck) else {
   ///             throw .generic(userFriendlyMessage: "File integrity compromised")
   ///         }
   ///         // Validation logic
   ///     }
   /// }
   /// ```
   case generic(userFriendlyMessage: String)

   /// An error that occurred during a file operation, wrapped into this error type using the ``catch(_:)`` function.
   /// This could include system-level file errors, encoding/decoding errors, or any other errors encountered during file operations.
   ///
   /// # Example
   /// ```swift
   /// struct DocumentStorage {
   ///     func saveDocument(_ document: Document) throws(FileError) {
   ///         // Regular error for missing file
   ///         guard fileExists(document.path) else {
   ///             throw FileError.fileNotFound(fileName: document.name)
   ///         }
   ///
   ///         // Automatically wrap encoding and file system errors
   ///         try FileError.catch {
   ///             let data = try JSONEncoder().encode(document)
   ///             try data.write(to: document.url, options: .atomic)
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
   ///   - error: The original error that occurred during the file operation.
   case caught(Error)

   /// A user-friendly error message suitable for display to end users.
   public var userFriendlyMessage: String {
      switch self {
      case .fileNotFound(let fileName):
         return String.localized(
            key: "BuiltInErrors.FileError.fileNotFound",
            defaultValue: "The file \(fileName) could not be located. Please verify the file path and try again."
         )
      case .readFailed(let fileName):
         return String.localized(
            key: "BuiltInErrors.FileError.readError",
            defaultValue: "An error occurred while attempting to read the file \(fileName). Please check file permissions and try again."
         )
      case .writeFailed(let fileName):
         return String.localized(
            key: "BuiltInErrors.FileError.writeError",
            defaultValue: "Unable to write to the file \(fileName). Ensure you have the necessary permissions and try again."
         )
      case .generic(let userFriendlyMessage):
         return userFriendlyMessage
      case .caught(let error):
         return ErrorKit.userFriendlyMessage(for: error)
      }
   }
}
