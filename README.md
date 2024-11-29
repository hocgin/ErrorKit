# ErrorKit

ErrorKit makes error handling in Swift more intuitive. It reduces boilerplate while providing more insights. Helpful for users, fun for developers!

TODO: list all the advantages when using ErrorKit over Swift's native types

## Why we are introducing the `Throwable` protocol to replace `Error`

### Confusing `Error` API

The `Error` type in Swift is a very simple protocol that has no requirements. But it has exactly one computed property we can call named `localizedDescription` which returns a text we can log or show users.

You might have written something like this, providing a `localizedDescription`:

```swift
enum NetworkError: Error, CaseIterable {
   case noConnectionToServer
   case parsingFailed

   var localizedDescription: String {
      switch self {
      case .noConnectionToServer:
         return "No Connection to Server Established"

      case .parsingFailed:
         return "Parsing Failed"
      }
   }
}
```

But actually, this doesn't work. If we randomly throw an error and print it's `localizedDescription` like in this view:

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

The console output is cryptic and not at all what we would expect: 😱

```bash
Caught error with message: The operation couldn’t be completed. (ErrorKitDemo.NetworkError error 0.)
```

There is zero info about what error case was thrown – heck, not even the enum case name was provided, let alone our provided message! Why is that? That's because the Swift `Error` type is actually bridged to `NSError` which works entirely differently (with `domain`, `code`, and `userInfo`).

The correct way in Swift to provide your own error type is actually to conform to `LocalizedError`! It has the following requirements: `errorDescription: String?`, `failureReason: String?`, `recoverySuggestion: String?`, and `helpAnchor: String?`.

But all of these are optional, so you won't get any build errors when writing your own error types, making it easy to forget providing a user-friendly message. And the only field that is being used for `localizedDescription` actually is `errorDescription`, the failure reason or recovery suggestions, for example, get completely ignored. And the help anchor is a legacy leftover from old macOS error dialogs, it's very uncommon nowadays.

All this makes `LocalizedError` confusing and unsafe to use. Which is why we provide our own protocol:

```swift
public protocol Throwable: LocalizedError {
   var localizedDescription: String { get }
}
```

It is super simple and clear. We named it `Throwable` which is consistent with the `throw` keyword and has the common `able` ending used for protocols in Swift (like `Codable`, `Identifiable` and many others). And it actually requires a field and that field is named exactly like the `localizedDescription` we call when catching errors in Swift, making errors intuitive to write.

With this we can simply write:

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

Now when printing `error.localizedDescription` we get exactly the message we expect! 🥳

But it doesn't end there. We know that not all apps are localized, and not all developer have the time to localize all their errors right away. So we even provide a shorter version that you can use in your first iteration if your cases have no parameters. Just provide raw values like so, making your error type definition even shorter while maintaining descriptive error message:

```swift
enum NetworkError: String, Throwable, CaseIterable {
   case noConnectionToServer = "Unable to connect to the server."
   case parsingFailed = "Data parsing failed."
}
```

Section summary:

> We recommend conforming all your custom error types to `Throwable` rather than `Error` or `LocalizedError`. It has one requirement, `localizedDescription: String`, which will be exactly what you expect it to be.
