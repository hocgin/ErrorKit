# ErrorKit

ErrorKit makes error handling in Swift more intuitive. It reduces boilerplate code while providing clearer insights into errors - helpful for users, fun for developers!

## The Problem with Swift's Error Protocol

Swift's `Error` protocol appears simple with no requirements, but it's deceptively complex due to its historical NSError bridging. This leads to a common frustrating situation:

```swift
enum NetworkError: Error {
   case noConnectionToServer
   case parsingFailed

   var errorDescription: String {
      switch self {
      case .noConnectionToServer: "No connection to the server."
      case .parsingFailed: "Data parsing failed."
      }
   }
}
```

When you catch and print this error, you'd expect to see your custom message. Instead, you get something completely different:

```
"The operation couldn't be completed. (ErrorKitDemo.NetworkError error 0.)"
```

This happens because Swift's `Error` protocol's bridging to `NSError` uses `domain`, `code`, and `userInfo` behind the scenes. Your `errorDescription` property doesn't integrate with this system as you might expect.

## Key Features

ErrorKit offers a suite of opt-in features to solve common error handling challenges. Use what you need and ignore the rest!

### The Throwable Protocol

`Throwable` fixes the confusion of Swift's `Error` protocol by providing a clear, Swift-native approach to error handling:

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

Now when catching this error, you'll see exactly what you expect:
```
"Unable to connect to the server."
```

For rapid development, you can do:

```swift
enum NetworkError: String, Throwable {
   case noConnectionToServer = "Unable to connect to the server."
   case parsingFailed = "Data parsing failed."
}
```

The `Throwable` protocol automatically maps these raw values to your error messages, saving time during the initial development phase when you're implementing error types step by step.

`Throwable` is not a secondary system – it's a drop-in replacement for `Error` that works perfectly with all existing error propagation. Any type that conforms to `Throwable` automatically conforms to `Error` without the confusion!

[Read more about Throwable →](documentation/throwable)

### Enhanced Error Descriptions

Get improved, user-friendly messages for ANY error, including system errors:

```swift
do {
    let _ = try Data(contentsOf: url)
} catch {
    // Better than localizedDescription, works with any error type
    print(ErrorKit.userFriendlyMessage(for: error))
    // "You are not connected to the Internet. Please check your connection."
}
```

These enhanced descriptions are community-provided and fully localized mappings of common system errors to clearer, more actionable messages. Contributions are welcome – help improve error messages for everyone by submitting better descriptions for common errors!

[Read more about Enhanced Error Descriptions →](documentation/enhanced-descriptions)

### Typed Throws with Error Nesting

These complementary features enable type-safe error handling and clean error propagation.

#### Typed Throws

Type-specific `throws` declarations in Swift 6 provide compile-time checking of error handling:

```swift
do {
  try FileManager.default.throwableCreateDirectory(at: directoryURL)
} catch FileManagerError.noWritePermission {
  // Handle specific error with custom logic
} catch {
  showErrorDialog(error.localizedDescription)
}
```

#### Error Nesting with Catching

The `Catching` protocol solves the biggest problem with error handling: nested errors. Whenever you see you're returning your error type but need to call functions that throw other error types, that's when you need `Catching`:

```swift
enum ProfileError: Throwable, Catching {
    case validationFailed(field: String)
    case caught(Error)  // Single case handles all nested errors!
    
    var userFriendlyMessage: String { /* ... */ }
}

struct ProfileRepository {
    func loadProfile(id: String) throws(ProfileError) -> UserProfile {
        // Regular error throwing for validation
        guard id.isValidFormat else {
            throw ProfileError.validationFailed(field: "id")
        }
        
        // Automatically wrap any database or file errors
        let userData = try ProfileError.catch {
            let user = try database.loadUser(id)
            let settings = try fileSystem.readUserSettings(user.settingsPath)
            return UserProfile(user: user, settings: settings)
        }
        
        // Use the loaded data
        return userData
    }
}
```

Note how `ProfileError.catch` wraps any errors from the database or file operations into the `caught` case while still passing through the return value when successful.

#### Error Chain Debugging

When using `Throwable` with the `Catching` protocol and its `catch` function, you get powerful error chain debugging to understand exactly how errors propagate through your app layers:

```swift
do {
    try await updateUserProfile()
} catch {
    Logger().error("\(ErrorKit.errorChainDescription(for: error))")
    
    // Output shows the complete error path:
    // ProfileError
    // └─ DatabaseError
    //    └─ FileError.notFound(path: "/Users/data.db")
    //       └─ userFriendlyMessage: "Could not find database file."
}
```

[Read more about Typed Throws and Error Nesting →](documentation/typed-throws-nesting)

### Built-in Error Types

Stop reinventing common error types in every project. ErrorKit provides standardized error types for common scenarios:

```swift
func fetchUserData() throws(DatabaseError) {
    guard isConnected else {
        throw .connectionFailed
    }
    // Fetching logic
}
```

Includes ready-to-use types like `DatabaseError`, `NetworkError`, `FileError`, `ValidationError`, `PermissionError`, and more - all conforming to both `Throwable` and `Catching` with localized messages.

For quick one-off errors without defining a custom type, use `GenericError`:

```swift
func quickOperation() throws {
    guard condition else {
        throw GenericError(userFriendlyMessage: "The operation couldn't be completed due to invalid state.")
    }
    // Operation logic
}
```

`GenericError` is perfect during development when you need proper error messages without defining custom error types. You can always replace it with a more specific error type later when needed.

[Read more about Built-in Error Types →](documentation/built-in-types)

### User Feedback with Error Logs

Gathering diagnostic information from users has never been simpler:

```swift
Button("Report a Problem") {
    showMailComposer = true
}
.mailComposer(
    isPresented: $showMailComposer,
    recipient: "support@yourapp.com",
    subject: "Bug Report",
    messageBody: "Please describe what happened:",
    attachments: [
        try? ErrorKit.logAttachment(ofLast: .minutes(30))
    ]
)
```

With just a simple SwiftUI modifier, you can automatically include all log messages from Apple's Logging system (OSLog). 

Apple's unified logging system (`OSLog`/`Logger`) provides powerful structured logging that's better than using `print()`:

```swift
import OSLog

Logger().debug("Detailed connection info")              // Development debugging
Logger().info("User tapped submit button")              // General information
Logger().notice("Profile successfully loaded")          // Important events
Logger().warning("Low disk space detected")             // Alias for error
Logger().error("Failed to load user data")              // Errors that should be fixed
```

ErrorKit can collect these logs based on level, giving you complete context for user-reported issues.

[Read more about User Feedback and Logging →](documentation/user-feedback)

## Documentation

Visit our [full documentation](https://FlineDev.github.io/ErrorKit/documentation/) for detailed guides on each feature. The documentation is organized into independent guides that you can adopt one at a time as needed. This README is just an overview of what's available in ErrorKit.
