import Foundation

extension String {
   #if canImport(CryptoKit)
   // On Apple platforms, use the modern localization API with Bundle.module
   static func localized(key: StaticString, defaultValue: String.LocalizationValue) -> String {
      return String(
         localized: key,
         defaultValue: defaultValue,
         bundle: Bundle.module
      )
   }
   #else
   // On non-Apple platforms, just return the default value (the English translation)
   static func localized(key: StaticString, defaultValue: String) -> String {
      return defaultValue
   }
   #endif
}

extension String.StringInterpolation {
   mutating public func appendInterpolation(error: some Error) {
      appendInterpolation(ErrorKit.userFriendlyMessage(for: error))
   }

   mutating public func appendInterpolation(errorChain error: some Error) {
      appendInterpolation(ErrorKit.errorChainDescription(for: error))
   }
}
