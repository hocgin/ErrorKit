#if canImport(MapKit)
import MapKit
#endif

extension ErrorKit {
   static func enhancedMapKitDescription(for error: Error) -> String? {
      #if canImport(MapKit)
      if let mkError = error as? MKError {
         switch mkError.code {
         case .unknown:
            return String(
               localized: "CommonErrors.MKError.unknown",
               defaultValue: "An unknown error occurred in MapKit.",
               bundle: .module
            )
         case .serverFailure:
            return String(
               localized: "CommonErrors.MKError.serverFailure",
               defaultValue: "The MapKit server returned an error. Please try again later.",
               bundle: .module
            )
         case .loadingThrottled:
            return String(
               localized: "CommonErrors.MKError.loadingThrottled",
               defaultValue: "Map loading is being throttled. Please wait a moment and try again.",
               bundle: .module
            )
         case .placemarkNotFound:
            return String(
               localized: "CommonErrors.MKError.placemarkNotFound",
               defaultValue: "The requested placemark could not be found. Please check the location details.",
               bundle: .module
            )
         case .directionsNotFound:
            return String(
               localized: "CommonErrors.MKError.directionsNotFound",
               defaultValue: "No directions could be found for the specified route.",
               bundle: .module
            )
         default:
            return String(
               localized: "CommonErrors.MKError.default",
               defaultValue: "A MapKit error occurred: \(mkError.localizedDescription)",
               bundle: .module
            )
         }
      }
      #endif

      return nil
   }
}
