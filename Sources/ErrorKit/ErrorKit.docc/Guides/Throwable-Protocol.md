# Throwable Protocol

Making error messages work as expected in Swift with a more intuitive protocol.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "Throwable")
}

## Highlights

Swift's built-in `Error` protocol has a confusing quirk: custom `localizedDescription` messages don't work as expected. ErrorKit solves this with the `Throwable` protocol, ensuring your error messages always appear as intended.

### The Problem with Swift's Error Protocol

When you create a custom error type in Swift with a `localizedDescription` property:

```swift
enum NetworkError: Error {
   case noConnectionToServer
   case parsingFailed

   var localizedDescription: String {
      switch self {
      case .noConnectionToServer: "No connection to the server."
      case .parsingFailed: "Data parsing failed."
      }
   }
}
```

You expect to see your custom message when catching the error:

```swift
do {
   throw NetworkError.noConnectionToServer
} catch {
   print(error.localizedDescription)
   // Expected: "No connection to the server."
   // Actual: "The operation couldn't be completed. (MyApp.NetworkError error 0.)"
}
```

Your custom message never appears! This happens because Swift's `Error` protocol is bridged to `NSError` behind the scenes, which uses a completely different system for error messages with `domain`, `code`, and `userInfo` dictionaries.

### The Solution: Throwable Protocol

ErrorKit introduces the `Throwable` protocol to solve this problem:

```swift
enum NetworkError: Throwable {
   case noConnectionToServer
   case parsingFailed

   var userFriendlyMessage: String {
      switch self {
      case .noConnectionToServer: String(localized: "Unable to connect to the server.")
      case .parsingFailed: String(localized: "Data parsing failed.")
      }
   }
}
```

Now when you catch errors:

```swift
do {
   throw NetworkError.noConnectionToServer
} catch {
   print(error.localizedDescription)
   // Now correctly shows: "Unable to connect to the server."
}
```

The `Throwable` protocol handles all the mapping between your custom messages and Swift's error system, so you get exactly the behavior you'd expect.

### Quick Start with Raw Values

For rapid development and prototyping, `Throwable` automatically works with string raw values:

```swift
enum NetworkError: String, Throwable {
   case noConnectionToServer = "Unable to connect to the server."
   case parsingFailed = "Data parsing failed."
}
```

This eliminates boilerplate by automatically using the raw string values as your error messages. It's perfect for quickly implementing error types during active development before adding proper localization later.

### Complete Drop-in Replacement

`Throwable` is designed as a complete drop-in replacement for `Error`:

```swift
// Standard Swift error-handling works exactly the same
func validateUser(name: String) throws {
   guard name.count >= 3 else {
      throw ValidationError.tooShort
   }
}

// Works with all existing Swift error patterns
do {
   try validateUser(name: "Jo")
} catch let error as ValidationError {
   // Type-based catching works
   handleValidationError(error)
} catch {
   // General error catching works
   handleGenericError(error)
}
```

Any type that conforms to `Throwable` automatically conforms to `Error`, so you can use it with all existing Swift error handling patterns with no changes to your architecture.

## Topics

### Essentials

- ``Throwable``

### Default Implementations

- ``Swift/RawRepresentable/userFriendlyMessage``

### Error Handling

- ``ErrorKit/userFriendlyMessage(for:)``
