import Foundation

#if canImport(FoundationNetworking)
   import FoundationNetworking
#endif

enum FoundationErrorMapper: ErrorMapper {
   static func userFriendlyMessage(for error: Error) -> String? {
      switch error {

      // URLError: Networking errors
      case let urlError as URLError:
         switch urlError.code {
         case .notConnectedToInternet:
            return String.localized(
               key: "EnhancedDescriptions.URLError.notConnectedToInternet",
               defaultValue: "You are not connected to the Internet. Please check your connection."
            )
         case .timedOut:
            return String.localized(
               key: "EnhancedDescriptions.URLError.timedOut",
               defaultValue: "The request timed out. Please try again later."
            )
         case .cannotFindHost:
            return String.localized(
               key: "EnhancedDescriptions.URLError.cannotFindHost",
               defaultValue: "Unable to find the server. Please check the URL or your network."
            )
         case .networkConnectionLost:
            return String.localized(
               key: "EnhancedDescriptions.URLError.networkConnectionLost",
               defaultValue: "The network connection was lost. Please try again."
            )
         default:
            return String.localized(
               key: "EnhancedDescriptions.URLError.default",
               defaultValue: "A network error occurred: \(urlError.localizedDescription)"
            )
         }

      // CocoaError: File-related errors
      case let cocoaError as CocoaError:
         switch cocoaError.code {
         case .fileNoSuchFile:
            return String.localized(
               key: "EnhancedDescriptions.CocoaError.fileNoSuchFile",
               defaultValue: "The file could not be found."
            )
         case .fileReadNoPermission:
            return String.localized(
               key: "EnhancedDescriptions.CocoaError.fileReadNoPermission",
               defaultValue: "You do not have permission to read this file."
            )
         case .fileWriteOutOfSpace:
            return String.localized(
               key: "EnhancedDescriptions.CocoaError.fileWriteOutOfSpace",
               defaultValue: "There is not enough disk space to complete the operation."
            )
         default:
            return String.localized(
               key: "EnhancedDescriptions.CocoaError.default",
               defaultValue: "A file system error occurred: \(cocoaError.localizedDescription)"
            )
         }

      // POSIXError: POSIX errors
      case let posixError as POSIXError:
         switch posixError.code {
         case .ENOSPC:
            return String.localized(
               key: "EnhancedDescriptions.POSIXError.ENOSPC",
               defaultValue: "There is no space left on the device."
            )
         case .EACCES:
            return String.localized(
               key: "EnhancedDescriptions.POSIXError.EACCES",
               defaultValue: "Permission denied. Please check your file permissions."
            )
         case .EBADF:
            return String.localized(
               key: "EnhancedDescriptions.POSIXError.EBADF",
               defaultValue: "Bad file descriptor. The file may be closed or invalid."
            )
         default:
            return String.localized(
               key: "EnhancedDescriptions.POSIXError.default",
               defaultValue: "A system error occurred: \(posixError.localizedDescription)"
            )
         }

      default:
         return nil
      }
   }
}
