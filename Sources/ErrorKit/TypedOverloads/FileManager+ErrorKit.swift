import Foundation

/// An enumeration that represents various errors that can occur when performing file management operations.
public enum FileManagerError: Throwable {
   /// The specified file or directory could not be found.
   /// - This error occurs when an operation targets a file or directory that doesn't exist.
   case fileNotFound

   /// You do not have permission to read the specified file or directory.
   /// - This error happens when the system denies read access due to permission restrictions.
   case noReadPermission

   /// You do not have permission to write to the specified file or directory.
   /// - This error occurs when the system denies write access due to permission restrictions.
   case noWritePermission

   /// There is not enough disk space to complete the operation.
   /// - This error occurs when the file system runs out of space while attempting to write or copy files.
   case outOfSpace

   /// The file name is invalid and cannot be used.
   /// - This error happens when the specified file name contains illegal characters or formats.
   case invalidFileName

   /// The file is corrupted or in an unreadable format.
   /// - This error occurs when attempting to read a file that is damaged or in an unsupported format.
   case corruptFile

   /// The file is locked and cannot be modified.
   /// - This error happens when attempting to modify or delete a file that is locked by another process or the system.
   case fileLocked

   /// An unknown error occurred while reading the file.
   /// - This error is thrown when an unexpected issue happens during a read operation that doesn't match other error types.
   case readError

   /// An unknown error occurred while writing the file.
   /// - This error is thrown when an unexpected issue happens during a write operation that doesn't match other error types.
   case writeError

   /// The file's character encoding is not supported.
   /// - This error occurs when the system cannot decode the file due to an unsupported character encoding.
   case unsupportedEncoding

   /// The file is too large to be processed.
   /// - This error occurs when a file exceeds system limits, such as memory constraints, making it impossible to handle.
   case fileTooLarge

   /// The storage volume is read-only and cannot be modified.
   /// - This error happens when attempting to modify a file on a read-only volume, such as a disk or network drive.
   case volumeReadOnly

   /// The file or directory already exists.
   /// - This error is thrown when attempting to create a file or directory that already exists at the specified location.
   case fileExists

   /// A general error case for any other unforeseen errors.
   /// - This error is used when the underlying error does not match any of the predefined cases and is passed as a wrapped error.
   case other(Error)

   /// Returns a user-friendly error message based on the error case.
   ///
   /// The message is localized for the user, with a default fallback message.
   public var userFriendlyMessage: String {
      switch self {
      case .fileNotFound:
         String.localized(
            key: "TypedOverloads.FileManager.fileNotFound",
            defaultValue: "The specified file or directory could not be found."
         )
      case .noReadPermission:
         String.localized(
            key: "TypedOverloads.FileManager.noReadPermission",
            defaultValue: "You do not have permission to read this file or directory."
         )
      case .noWritePermission:
         String.localized(
            key: "TypedOverloads.FileManager.noWritePermission",
            defaultValue: "You do not have permission to write to this file or directory."
         )
      case .outOfSpace:
         String.localized(
            key: "TypedOverloads.FileManager.outOfSpace",
            defaultValue: "There is not enough disk space to complete the operation."
         )
      case .invalidFileName:
         String.localized(
            key: "TypedOverloads.FileManager.invalidFileName",
            defaultValue: "The file name is invalid and cannot be used."
         )
      case .corruptFile:
         String.localized(
            key: "TypedOverloads.FileManager.corruptFile",
            defaultValue: "The file is corrupted or in an unreadable format."
         )
      case .fileLocked:
         String.localized(
            key: "TypedOverloads.FileManager.fileLocked",
            defaultValue: "The file is locked and cannot be modified."
         )
      case .readError:
         String.localized(
            key: "TypedOverloads.FileManager.readError",
            defaultValue: "An unknown error occurred while reading the file."
         )
      case .writeError:
         String.localized(
            key: "TypedOverloads.FileManager.writeError",
            defaultValue: "An unknown error occurred while writing the file."
         )
      case .unsupportedEncoding:
         String.localized(
            key: "TypedOverloads.FileManager.unsupportedEncoding",
            defaultValue: "The file's character encoding is not supported."
         )
      case .fileTooLarge:
         String.localized(
            key: "TypedOverloads.FileManager.fileTooLarge",
            defaultValue: "The file is too large to be processed."
         )
      case .volumeReadOnly:
         String.localized(
            key: "TypedOverloads.FileManager.volumeReadOnly",
            defaultValue: "The storage volume is read-only and cannot be modified."
         )
      case .fileExists:
         String.localized(
            key: "TypedOverloads.FileManager.fileExists",
            defaultValue: "The file or directory already exists."
         )
      case .other(let error):
         ErrorKit.userFriendlyMessage(for: error)
      }
   }
}

extension FileManager {
   /// A typed-throws overload of `createDirectory(at:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableCreateDirectory(
      at url: URL,
      withIntermediateDirectories createIntermediates: Bool = false,
      attributes: [FileAttributeKey: Any]? = nil
   ) throws(FileManagerError) {
      do {
         try self.createDirectory(at: url, withIntermediateDirectories: createIntermediates, attributes: attributes)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `createDirectory(atPath:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableCreateDirectory(
      atPath path: String,
      withIntermediateDirectories createIntermediates: Bool = false,
      attributes: [FileAttributeKey: Any]? = nil
   ) throws(FileManagerError) {
      do {
         try self.createDirectory(atPath: path, withIntermediateDirectories: createIntermediates, attributes: attributes)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `removeItem(at:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableRemoveItem(at url: URL) throws(FileManagerError) {
      do {
         try self.removeItem(at: url)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `removeItem(atPath:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableRemoveItem(atPath path: String) throws(FileManagerError) {
      do {
         try self.removeItem(atPath: path)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `copyItem(at:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableCopyItem(at sourceURL: URL, to destinationURL: URL) throws(FileManagerError) {
      do {
         try self.copyItem(at: sourceURL, to: destinationURL)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `copyItem(atPath:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableCopyItem(atPath sourcePath: String, toPath destinationPath: String) throws(FileManagerError) {
      do {
         try self.copyItem(atPath: sourcePath, toPath: destinationPath)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `moveItem(at:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableMoveItem(at sourceURL: URL, to destinationURL: URL) throws(FileManagerError) {
      do {
         try self.moveItem(at: sourceURL, to: destinationURL)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `moveItem(atPath:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableMoveItem(atPath sourcePath: String, toPath destinationPath: String) throws(FileManagerError) {
      do {
         try self.moveItem(atPath: sourcePath, toPath: destinationPath)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `attributesOfItem(atPath:)` that maps known errors to a custom ``FileManagerError`` enum for enhanced error handling.
   public func throwableAttributesOfItem(atPath path: String) throws(FileManagerError) -> [FileAttributeKey: Any] {
      do {
         return try self.attributesOfItem(atPath: path)
      } catch {
         throw self.mapToThrowable(error: error as NSError)
      }
   }

   private func mapToThrowable(error: NSError) -> FileManagerError {
      switch (error.domain, error.code) {
      case (NSCocoaErrorDomain, NSFileNoSuchFileError): .fileNotFound
      case (NSCocoaErrorDomain, NSFileReadNoPermissionError): .noReadPermission
      case (NSCocoaErrorDomain, NSFileWriteNoPermissionError): .noWritePermission
      case (NSCocoaErrorDomain, NSFileWriteOutOfSpaceError): .outOfSpace
      case (NSCocoaErrorDomain, NSFileWriteInvalidFileNameError): .invalidFileName
      case (NSCocoaErrorDomain, NSFileReadCorruptFileError): .corruptFile
      case (NSCocoaErrorDomain, NSFileLockingError): .fileLocked
      case (NSCocoaErrorDomain, NSFileReadUnknownError): .readError
      case (NSCocoaErrorDomain, NSFileWriteUnknownError): .writeError
      case (NSCocoaErrorDomain, NSFileReadInapplicableStringEncodingError): .unsupportedEncoding
      case (NSCocoaErrorDomain, NSFileReadTooLargeError): .fileTooLarge
      case (NSCocoaErrorDomain, NSFileWriteVolumeReadOnlyError): .volumeReadOnly
      case (NSCocoaErrorDomain, NSFileWriteFileExistsError): .fileExists
      default: .other(error)
      }
   }
}
