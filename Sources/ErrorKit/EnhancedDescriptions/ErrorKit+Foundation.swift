import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension ErrorKit {
   static func userFriendlyFoundationMessage(for error: Error) -> String? {
      switch error {

      // URLError: Networking errors
      case let urlError as URLError:
         switch urlError.code {
         case .notConnectedToInternet:
            return String(
               localized: "EnhancedDescriptions.URLError.notConnectedToInternet",
               defaultValue: "You are not connected to the Internet. Please check your connection.",
               bundle: .module
            )
         case .timedOut:
            return String(
               localized: "EnhancedDescriptions.URLError.timedOut",
               defaultValue: "The request timed out. Please try again later.",
               bundle: .module
            )
         case .cannotFindHost:
            return String(
               localized: "EnhancedDescriptions.URLError.cannotFindHost",
               defaultValue: "Unable to find the server. Please check the URL or your network.",
               bundle: .module
            )
         case .networkConnectionLost:
            return String(
               localized: "EnhancedDescriptions.URLError.networkConnectionLost",
               defaultValue: "The network connection was lost. Please try again.",
               bundle: .module
            )
         default:
            return String(
               localized: "EnhancedDescriptions.URLError.default",
               defaultValue: "A network error occurred: \(urlError.localizedDescription)",
               bundle: .module
            )
         }

      // CocoaError: File-related errors
      case let cocoaError as CocoaError:
         switch cocoaError.code {
         case .fileNoSuchFile:
            return String(
               localized: "EnhancedDescriptions.CocoaError.fileNoSuchFile",
               defaultValue: "The file could not be found.",
               bundle: .module
            )
         case .fileReadNoPermission:
            return String(
               localized: "EnhancedDescriptions.CocoaError.fileReadNoPermission",
               defaultValue: "You do not have permission to read this file.",
               bundle: .module
            )
         case .fileWriteOutOfSpace:
            return String(
               localized: "EnhancedDescriptions.CocoaError.fileWriteOutOfSpace",
               defaultValue: "There is not enough disk space to complete the operation.",
               bundle: .module
            )
         default:
            return String(
               localized: "EnhancedDescriptions.CocoaError.default",
               defaultValue: "A file system error occurred: \(cocoaError.localizedDescription)",
               bundle: .module
            )
         }

      // POSIXError: POSIX errors
      case let posixError as POSIXError:
         switch posixError.code {
         case .ENOSPC:
            return String(
               localized: "EnhancedDescriptions.POSIXError.ENOSPC",
               defaultValue: "There is no space left on the device.",
               bundle: .module
            )
         case .EACCES:
            return String(
               localized: "EnhancedDescriptions.POSIXError.EACCES",
               defaultValue: "Permission denied. Please check your file permissions.",
               bundle: .module
            )
         case .EBADF:
            return String(
               localized: "EnhancedDescriptions.POSIXError.EBADF",
               defaultValue: "Bad file descriptor. The file may be closed or invalid.",
               bundle: .module
            )
         default:
            return String(
               localized: "EnhancedDescriptions.POSIXError.default",
               defaultValue: "A system error occurred: \(posixError.localizedDescription)",
               bundle: .module
            )
         }

      default:
         return nil
      }
   }
}
