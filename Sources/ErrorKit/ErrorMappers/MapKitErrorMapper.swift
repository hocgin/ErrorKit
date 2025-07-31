#if canImport(MapKit)
   import MapKit
#endif

enum MapKitErrorMapper: ErrorMapper {
   static func userFriendlyMessage(for error: Error) -> String? {
      #if canImport(MapKit)
         if let mkError = error as? MKError {
            switch mkError.code {
            case .unknown:
               return String.localized(
                  key: "EnhancedDescriptions.MKError.unknown",
                  defaultValue: "An unknown error occurred in MapKit."
               )
            case .serverFailure:
               return String.localized(
                  key: "EnhancedDescriptions.MKError.serverFailure",
                  defaultValue: "The MapKit server returned an error. Please try again later."
               )
            case .loadingThrottled:
               return String.localized(
                  key: "EnhancedDescriptions.MKError.loadingThrottled",
                  defaultValue: "Map loading is being throttled. Please wait a moment and try again."
               )
            case .placemarkNotFound:
               return String.localized(
                  key: "EnhancedDescriptions.MKError.placemarkNotFound",
                  defaultValue: "The requested placemark could not be found. Please check the location details."
               )
            case .directionsNotFound:
               return String.localized(
                  key: "EnhancedDescriptions.MKError.directionsNotFound",
                  defaultValue: "No directions could be found for the specified route."
               )
            default:
               return String.localized(
                  key: "EnhancedDescriptions.MKError.default",
                  defaultValue: "A MapKit error occurred: \(mkError.localizedDescription)"
               )
            }
         }
      #endif

      return nil
   }
}
