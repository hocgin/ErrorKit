import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension ErrorKit {
   static func enhancedFoundationDescription(for error: Error) -> String? {
      switch error {

      // URLError: Networking errors
      case let urlError as URLError:
         switch urlError.code {
         case .notConnectedToInternet:
            return String(
               localized: "CommonErrors.URLError.notConnectedToInternet",
               defaultValue: "You are not connected to the Internet. Please check your connection.",
               bundle: .module
            )
         case .timedOut:
            return String(
               localized: "CommonErrors.URLError.timedOut",
               defaultValue: "The request timed out. Please try again later.",
               bundle: .module
            )
         case .cannotFindHost:
            return String(
               localized: "CommonErrors.URLError.cannotFindHost",
               defaultValue: "Unable to find the server. Please check the URL or your network.",
               bundle: .module
            )
         case .networkConnectionLost:
            return String(
               localized: "CommonErrors.URLError.networkConnectionLost",
               defaultValue: "The network connection was lost. Please try again.",
               bundle: .module
            )
         default:
            return String(
               localized: "CommonErrors.URLError.default",
               defaultValue: "A network error occurred: \(urlError.localizedDescription)",
               bundle: .module
            )
         }

      // CocoaError: File-related errors
      case let cocoaError as CocoaError:
         switch cocoaError.code {
         case .fileNoSuchFile:
            return String(
               localized: "CommonErrors.CocoaError.fileNoSuchFile",
               defaultValue: "The file could not be found.",
               bundle: .module
            )
         case .fileReadNoPermission:
            return String(
               localized: "CommonErrors.CocoaError.fileReadNoPermission",
               defaultValue: "You do not have permission to read this file.",
               bundle: .module
            )
         case .fileWriteOutOfSpace:
            return String(
               localized: "CommonErrors.CocoaError.fileWriteOutOfSpace",
               defaultValue: "There is not enough disk space to complete the operation.",
               bundle: .module
            )
         default:
            return String(
               localized: "CommonErrors.CocoaError.default",
               defaultValue: "A file system error occurred: \(cocoaError.localizedDescription)",
               bundle: .module
            )
         }

      // POSIXError: POSIX errors
      case let posixError as POSIXError:
         switch posixError.code {
         case .ENOSPC:
            return String(
               localized: "CommonErrors.POSIXError.ENOSPC",
               defaultValue: "There is no space left on the device.",
               bundle: .module
            )
         case .EACCES:
            return String(
               localized: "CommonErrors.POSIXError.EACCES",
               defaultValue: "Permission denied. Please check your file permissions.",
               bundle: .module
            )
         case .EBADF:
            return String(
               localized: "CommonErrors.POSIXError.EBADF",
               defaultValue: "Bad file descriptor. The file may be closed or invalid.",
               bundle: .module
            )
         default:
            return String(
               localized: "CommonErrors.POSIXError.default",
               defaultValue: "A system error occurred: \(posixError.localizedDescription)",
               bundle: .module
            )
         }

      default:
         return nil
      }
   }
}
