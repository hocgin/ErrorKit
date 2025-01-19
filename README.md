# ErrorKit

**ErrorKit** makes error handling in Swift more intuitive. It reduces boilerplate code while providing clearer insights. Helpful for users, fun for developers!

*TODO: Add a list of advantages of using ErrorKit over Swift’s native error handling types.*

---

## Why We Introduced the `Throwable` Protocol to Replace `Error`

### The Confusing `Error` API

Swift's `Error` protocol is simple – too simple. It has no requirements, but it offers one computed property, `localizedDescription`, which is often used to log errors or display messages to users.

Consider the following example where we provide a `localizedDescription` for an enum:

```swift
enum NetworkError: Error, CaseIterable {
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

You might expect this to work seamlessly, but it doesn’t. If we randomly throw an error and print its `localizedDescription`, like in the following SwiftUI view:

```swift
struct ContentView: View {
   var body: some View {
      Button("Throw Random NetworkError") {
         do {
            throw NetworkError.allCases.randomElement()!
         } catch {
            print("Caught error with message: \(error.localizedDescription)")
         }
      }
   }
}
```

The console output will surprise you: 😱

```bash
Caught error with message: The operation couldn’t be completed. (ErrorKitDemo.NetworkError error 0.)
```

There’s no information about the specific error case. Not even the enum case name appears, let alone the custom message! Why? Because Swift’s `Error` protocol is bridged to `NSError`, which uses `domain`, `code`, and `userInfo` instead.

### The "Correct" Way: `LocalizedError`

The correct approach is to conform to `LocalizedError`, which defines the following optional properties:  

- `errorDescription: String?`
- `failureReason: String?`
- `recoverySuggestion: String?`
- `helpAnchor: String?`

However, since all of these properties are optional, you won’t get any compiler errors if you forget to implement them. Worse, only `errorDescription` affects `localizedDescription`. Fields like `failureReason` and `recoverySuggestion` are ignored, while `helpAnchor` is rarely used nowadays.

This makes `LocalizedError` both confusing and error-prone.

### The Solution: `Throwable`

To address these issues, **ErrorKit** introduces the `Throwable` protocol:

```swift
public protocol Throwable: LocalizedError {
   var userFriendlyMessage: String { get }
}
```

This protocol is simple and clear. It’s named `Throwable` to align with Swift’s `throw` keyword and follows Swift’s convention of using the `able` suffix (like `Codable` and `Identifiable`). Most importantly, it requires the `userFriendlyMessage` property, ensuring your errors behave exactly as expected.

Here’s how you use it:

```swift
enum NetworkError: Throwable {
   case noConnectionToServer
   case parsingFailed

   var userFriendlyMessage: String {
      switch self {
      case .noConnectionToServer: "Unable to connect to the server."
      case .parsingFailed: "Data parsing failed."
      }
   }
}
```

When you print `error.localizedDescription`, you'll get exactly the message you expect! 🥳

### Even Shorter Error Definitions

Not all apps are localized, and developers may not have time to provide localized descriptions immediately. To make error handling even simpler, `Throwable` allows you to define your error messages using raw values:

```swift
enum NetworkError: String, Throwable {
   case noConnectionToServer = "Unable to connect to the server."
   case parsingFailed = "Data parsing failed."
}
```

This approach eliminates boilerplate code while keeping the error definitions concise and descriptive.

### Summary

> Conform your custom error types to `Throwable` instead of `Error` or `LocalizedError`. The `Throwable` protocol requires only `userFriendlyMessage: String`, ensuring your error messages are exactly what you expect – no surprises.


## Enhanced Error Descriptions with `userFriendlyMessage(for:)`

ErrorKit goes beyond simplifying error handling — it enhances the clarity of error messages by providing improved, localized descriptions. With the `ErrorKit.userFriendlyMessage(for:)` function, developers can deliver clear, user-friendly error messages tailored to their audience.

### How It Works

The `userFriendlyMessage(for:)` function analyzes the provided `Error` and returns an enhanced, localized message. It draws on a community-maintained collection of descriptions to ensure the messages are accurate, helpful, and continuously evolving.

### Supported Error Domains

ErrorKit supports errors from various domains such as `Foundation`, `CoreData`, `MapKit`, and more. These domains are continuously updated, providing coverage for the most common error types in Swift development.

### Usage Example

Here’s how to use `userFriendlyMessage(for:)` to handle errors gracefully:

```swift
do {
    // Attempt a network request
    let url = URL(string: "https://example.com")!
    let _ = try Data(contentsOf: url)
} catch {
    // Print or show the enhanced error message to a user
    print(ErrorKit.userFriendlyMessage(for: error))
    // Example output: "You are not connected to the Internet. Please check your connection."
}
```

### Why Use `userFriendlyMessage(for:)`?

- **Localization**: Error messages are localized to ~40 languages to provide a better user experience.
- **Clarity**: Returns clear and concise error messages, avoiding cryptic system-generated descriptions.
- **Community Contributions**: The descriptions are regularly improved by the developer community. If you encounter a new or unexpected error, feel free to contribute by submitting a pull request.

### Contribution Welcome!

Found a bug or missing description? We welcome your contributions! Submit a pull request (PR), and we’ll gladly review and merge it to enhance the library further.

> **Note:** The enhanced error descriptions are constantly evolving, and we’re committed to making them as accurate and helpful as possible.

## Overloads of Common System Functions with Typed Throws

ErrorKit introduces typed-throws overloads for common system APIs like `FileManager` and `URLSession`, providing more granular error handling and improved code clarity. These overloads allow you to handle specific error scenarios with tailored responses, making your code more robust and easier to maintain.

To streamline discovery, ErrorKit uses the same API names prefixed with `throwable`. These functions throw specific errors that conform to `Throwable`, allowing for clear and informative error messages.

**Enhanced User-Friendly Error Messages:**

One of the key advantages of ErrorKit's typed throws is the improved `localizedDescription` property. This property provides user-friendly error messages that are tailored to the specific error type. This eliminates the need for manual error message construction and ensures a consistent and informative user experience.

**Example: Creating a Directory**

```swift
do {
  try FileManager.default.throwableCreateDirectory(at: URL(string: "file:///path/to/directory")!)
} catch {
   switch error {
   case FileManagerError.noWritePermission:
      // Request write permission from the user intead of showing error message
   default:
      // Common error cases have a more descriptive message
      showErrorDialog(error.localizedDescription)
   }
}
```

The code demonstrates how to handle errors for specific error cases with an improved UX rather than just showing an error message to the user, which can still be the fallback. And the error cases are easy to discover thanks to the typed enum error.

**Example: Handling network request errors**

```swift
do {
  let (data, response) = try await URLSession.shared.throwableData(from: URL(string: "https://api.example.com/data")!)
  // Process the data and response
} catch {
  // Error is of type `URLSessionError`
  print(error.localizedDescription)

  switch error {
  case .timeout, .requestTimeout, .tooManyRequests:
    // Automatically retry the request with a backoff strategy
  case .noNetwork:
    // Show an SF Symbol indicating the user is offline plus a retry button
  case .unauthorized:
    // Redirect the user to your login-flow (e.g. because token expired)
  default:
    // Fall back to showing error message
  }
}
```

Here, the code leverages the specific error types to implement various kinds of custom logic. This demonstrates the power of typed throws in providing fine-grained control over error handling.

### Summary

By utilizing these typed-throws overloads, you can write more robust and maintainable code. ErrorKit's enhanced user-friendly messages and ability to handle specific errors with code lead to a better developer and user experience. As the library continues to evolve, we encourage the community to contribute additional overloads and error types for common system APIs to further enhance its capabilities.


## Built-in Error Types for Common Scenarios

ErrorKit provides a set of pre-defined error types for common scenarios that developers encounter frequently. These built-in types conform to `Throwable` and can be used with both typed throws (`throws(DatabaseError)`) and classical throws declarations.

### Why Built-in Types?

Built-in error types offer several advantages:
- **Quick Start**: Begin with well-structured error handling without defining custom types
- **Consistency**: Use standardized error cases and messages across your codebase
- **Flexibility**: Easily transition to custom error types when you need more specific cases
- **Discoverability**: Clear naming conventions make it easy to find the right error type
- **Localization**: All error messages are pre-localized and user-friendly
- **Ecosystem Impact**: As more Swift packages adopt these standardized error types, apps can implement smarter error handling that works across dependencies. Instead of just showing error messages, apps could provide specific UI or recovery actions for known error types, creating a more cohesive error handling experience throughout the ecosystem.

### Available Error Types

ErrorKit includes the following built-in error types:

- **DatabaseError** (connectionFailed, operationFailed, recordNotFound)
- **FileError** (fileNotFound, readFailed, writeFailed)
- **NetworkError** (noInternet, timeout, badRequest, serverError, decodingFailure)
- **OperationError** (dependencyFailed, canceled, unknownFailure)
- **ParsingError** (invalidInput, missingField, inputTooLong)
- **PermissionError** (denied, restricted, notDetermined)
- **StateError** (invalidState, alreadyFinalized, preconditionFailed)
- **ValidationError** (invalidInput, missingField, inputTooLong)
- **GenericError** (for ad-hoc custom messages)

All built-in error types include a `generic` case that accepts a custom `userFriendlyMessage`, allowing for quick additions of edge cases without creating new error types. Use the `GenericError` struct when you want to quickly throw a one-off error without having to define your own type if none of the other fit, useful especially during early phases of development. 

### Usage Examples

```swift
func fetchUserData() throws(DatabaseError) {
    guard isConnected else {
        throw .connectionFailed
    }
    // Fetching logic
}

// Or with classical throws
func processData() throws {
    guard isValid else {
        throw ValidationError.invalidInput(field: "email")
    }
    // Processing logic
}

// Quick error throwing with GenericError
func quickOperation() throws {
    guard condition else {
        throw GenericError(userFriendlyMessage: String(localized: "The condition X was not fulfilled, please check again."))
    }
    // Operation logic
}

// Using generic case for edge cases
func handleSpecialCase() throws(DatabaseError) {
    guard specialCondition else {
        throw .generic(userFriendlyMessage: String(localized: "Database is in maintenance mode"))
    }
    // Special case handling
}
```

### Contributing New Error Types

We need your help! If you find yourself:
- Defining similar error types across projects
- Missing a common error scenario in our built-in types
- Seeing patterns in error handling that could benefit others
- Having ideas for better error messages or new cases

Please contribute! Submit a pull request to add your error types or cases to ErrorKit. Your contribution helps build a more robust error handling ecosystem for Swift developers.

When contributing:
- Ensure error cases are generic enough for broad use
- Provide clear, actionable error messages
- Include real-world usage examples in documentation
- Follow the existing naming conventions

Together, we can build a comprehensive set of error types that cover most common scenarios in Swift development and create a more unified error handling experience across the ecosystem.


## Simplified Error Nesting with the `Catching` Protocol

ErrorKit's `Catching` protocol simplifies error handling in modular applications by providing an elegant way to handle nested error hierarchies. It eliminates the need for explicit wrapper cases while maintaining type safety through typed throws.

### The Problem with Manual Error Wrapping

In modular applications, errors often need to be propagated up through multiple layers. The traditional approach requires defining explicit wrapper cases for each possible error type:

```swift
enum ProfileError: Error {
    case validationFailed(field: String)
    case databaseError(DatabaseError)    // Wrapper case needed
    case networkError(NetworkError)      // Another wrapper case
    case fileError(FileError)           // Yet another wrapper
}

// And manual error wrapping in code:
 do {
     try database.fetch(id)
 } catch let error as DatabaseError {
     throw .databaseError(error)
 }
```

This leads to verbose error types and tedious error handling code when attempting to use typed throws.

### The Solution: `Catching` Protocol

ErrorKit's `Catching` protocol provides a single `caught` case that can wrap any error, plus a convenient `catch` function for automatic error wrapping:

```swift
enum ProfileError: Throwable, Catching {
    case validationFailed(field: String)
    case caught(Error)  // Single case handles all nested errors!
}

struct ProfileRepository {
    func loadProfile(id: String) throws(ProfileError) {
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
    }
}
```

Note the `ProfileError.catch` function call, which wraps any errors into the `caught` case and also passes through the return type.

### Built-in Support in ErrorKit Types

All of ErrorKit's built-in error types (`DatabaseError`, `FileError`, `NetworkError`, etc.) already conform to `Catching`, allowing you to easily wrap system errors or other error types:

```swift
func saveUserData() throws(DatabaseError) {
    // Automatically wraps SQLite errors, file system errors, etc.
    try DatabaseError.catch {
        try database.beginTransaction()
        try database.execute(query)
        try database.commit()
    }
}
```

### Adding Catching to Your Error Types

Making your own error types support automatic error wrapping is simple:

1. Conform to the `Catching` protocol
2. Add the `caught(Error)` case to your error type
3. Use the `catch` function for automatic wrapping

```swift
enum AppError: Throwable, Catching {
    case invalidConfiguration
    case caught(Error)  // Required for Catching protocol
    
    var userFriendlyMessage: String {
        switch self {
        case .invalidConfiguration:
            return String(localized: "The app configuration is invalid.")
        case .caught(let error):
            return ErrorKit.userFriendlyMessage(for: error)
        }
    }
}

// Usage is clean and simple:
func appOperation() throws(AppError) {
    // Explicit error throwing for known cases
    guard configFileExists else {
        throw AppError.invalidConfiguration
    }
    
    // Automatic wrapping for system errors and other error types
    try AppError.catch {
        try riskyOperation()
        try anotherRiskyOperation()
    }
}
```

### Benefits of Using `Catching`

- **Less Boilerplate**: No need for explicit wrapper cases for each error type
- **Type Safety**: Maintains typed throws while simplifying error handling
- **Clean Code**: Reduces error handling verbosity
- **Automatic Message Propagation**: User-friendly messages flow through the error chain
- **Easy Integration**: Works seamlessly with existing error types
- **Return Value Support**: The `catch` function preserves return values from wrapped operations

### Best Practices

- Use `Catching` for error types that might wrap other errors
- Keep error hierarchies shallow when possible
- Use specific error cases for known errors, `caught` for others
- Preserve user-friendly messages when wrapping errors
- Consider error recovery strategies at each level

The `Catching` protocol makes error handling in Swift more intuitive and maintainable, especially in larger applications with complex error hierarchies. Combined with typed throws, it provides a powerful way to handle errors while keeping your code clean and maintainable.
