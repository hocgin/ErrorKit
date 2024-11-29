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

However, since all of these properties are optional, you won’t get any compiler errors if you forget to implement them. Worse, only `errorDescription` affects `localizedDescription`. Fields like `failureReason` and `recoverySuggestion` are ignored, while `helpAnchor` is rarely used today.

This makes `LocalizedError` both confusing and error-prone.

### The Solution: `Throwable`

To address these issues, **ErrorKit** introduces the `Throwable` protocol:

```swift
public protocol Throwable: LocalizedError {
   var localizedDescription: String { get }
}
```

This protocol is simple and clear. It’s named `Throwable` to align with Swift’s `throw` keyword and follows Swift’s convention of using the `able` suffix (like `Codable` and `Identifiable`). Most importantly, it requires the `localizedDescription` property, ensuring your errors behave exactly as expected.

Here’s how you use it:

```swift
enum NetworkError: Throwable, CaseIterable {
   case noConnectionToServer
   case parsingFailed

   var localizedDescription: String {
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
enum NetworkError: String, Throwable, CaseIterable {
   case noConnectionToServer = "Unable to connect to the server."
   case parsingFailed = "Data parsing failed."
}
```

This approach eliminates boilerplate code while keeping the error definitions concise and descriptive.

### Summary

> Conform your custom error types to `Throwable` instead of `Error` or `LocalizedError`. The `Throwable` protocol requires only `localizedDescription: String`, ensuring your error messages are exactly what you expect – no surprises.
