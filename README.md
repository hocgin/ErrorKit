![ErrorKit Logo](https://github.com/FlineDev/ErrorKit/blob/main/Logo.png?raw=true)

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FFlineDev%2FErrorKit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/FlineDev/ErrorKit)

# ErrorKit

Making error handling in Swift more intuitive and powerful with clearer messages, type safety, and user-friendly diagnostics.

## Overview

Swift's error handling has several limitations that make it challenging to create robust, user-friendly applications:
- The `Error` protocol's confusing behavior with `localizedDescription`
- Hard-to-understand system error messages
- Limited type safety in error propagation
- Difficulties with error chain debugging (relevant for typed throws!)
- Challenges in collecting meaningful feedback from users

ErrorKit addresses these challenges with a suite of lightweight, interconnected features you can adopt progressively.

## Core Features

### The Throwable Protocol

`Throwable` fixes the confusion of Swift's `Error` protocol by providing a clear, Swift-native approach to error handling:

```swift
enum NetworkError: Throwable {
   case noConnectionToServer
   case parsingFailed

   var userFriendlyMessage: String {
      switch self {
      case .noConnectionToServer:
         String(localized: "Unable to connect to the server.")
      case .parsingFailed:
         String(localized: "Data parsing failed.")
      }
   }
}
```

Now when catching this error, you'll see exactly what you expect:
```
"Unable to connect to the server."
```

For rapid development, you can use string raw values:

```swift
enum NetworkError: String, Throwable {
   case noConnectionToServer = "Unable to connect to the server."
   case parsingFailed = "Data parsing failed."
}
```

[Read more about Throwable →](https://swiftpackageindex.com/FlineDev/ErrorKit/documentation/errorkit/throwable-protocol)

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

These enhanced descriptions are community-provided and fully localized mappings of common system errors to clearer, more actionable messages.

[Read more about Enhanced Error Descriptions →](https://swiftpackageindex.com/FlineDev/ErrorKit/documentation/errorkit/enhanced-error-descriptions)

## Swift 6 Typed Throws Support

Swift 6 introduces typed throws (`throws(ErrorType)`), bringing compile-time type checking to error handling. ErrorKit makes this powerful feature practical with solutions for its biggest challenges:

### Error Nesting with Catching

The `Catching` protocol solves the biggest problem with error handling: nested errors.

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
        
        return userData
    }
}
```

[Read more about Typed Throws and Error Nesting →](https://swiftpackageindex.com/FlineDev/ErrorKit/documentation/errorkit/typed-throws-and-error-nesting)

### Error Chain Debugging

When using `Throwable` with the `Catching` protocol, you get powerful error chain debugging:

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

[Read more about Error Chain Debugging →](https://swiftpackageindex.com/FlineDev/ErrorKit/documentation/errorkit/error-chain-debugging)

## Ready-to-Use Tools

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

Includes ready-to-use types like `DatabaseError`, `NetworkError`, `FileError`, `ValidationError`, `PermissionError`, and more – all conforming to both `Throwable` and `Catching` with localized messages.

For quick one-off errors, use `GenericError`:

```swift
func quickOperation() throws {
    guard condition else {
        throw GenericError(userFriendlyMessage: "The operation couldn't be completed due to invalid state.")
    }
    // Operation logic
}
```

[Read more about Built-in Error Types →](https://swiftpackageindex.com/FlineDev/ErrorKit/documentation/errorkit/built-in-error-types)

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

With just a simple SwiftUI modifier, you can automatically include all log messages from Apple's unified logging system.

[Read more about User Feedback and Logging →](https://swiftpackageindex.com/FlineDev/ErrorKit/documentation/errorkit/user-feedback-with-logs)

## How These Features Work Together

ErrorKit's features are designed to complement each other while remaining independently useful:

1. **Start with improved error definitions** using `Throwable` for custom errors and `userFriendlyMessage(for:)` for system errors.

2. **Add type safety with Swift 6 typed throws**, using the `Catching` protocol to solve nested error challenges. This pairs with error chain debugging to understand error flows through your app.

3. **Save time with ready-made tools**: built-in error types for common scenarios and simple log collection for user feedback.

## Adoption Path

Here's a practical adoption strategy:

1. Replace `Error` with `Throwable` in your custom error types
2. Use `ErrorKit.userFriendlyMessage(for:)` when showing system errors
3. Adopt built-in error types where they fit your needs
4. Implement typed throws with `Catching` for more robust error flows
5. Add error chain debugging to improve error visibility
6. Integrate log collection with your feedback system

## Documentation

For complete documentation visit:
[ErrorKit Documentation](https://swiftpackageindex.com/FlineDev/ErrorKit/documentation/errorkit)

## Showcase

I created this library for my own Indie apps (download & rate them to show your appreciation):

<table>
  <tr>
    <th>App Icon</th>
    <th>App Name & Description</th>
    <th>Supported Platforms</th>
  </tr>
  <tr>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6476773066?pt=549314&ct=github.com&mt=8">
        <img src="https://raw.githubusercontent.com/FlineDev/HandySwiftUI/main/Images/Apps/TranslateKit.webp" width="64" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6476773066?pt=549314&ct=github.com&mt=8">
        <strong>TranslateKit: App Localization</strong>
      </a>
      <br />
      AI-powered app localization with unmatched accuracy. Fast & easy: AI & proofreading, 125+ languages, market insights. Budget-friendly, free to try.
    </td>
    <td>Mac</td>
  </tr>
  <tr>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6502914189?pt=549314&ct=github.com&mt=8">
        <img src="https://raw.githubusercontent.com/FlineDev/HandySwiftUI/main/Images/Apps/FreemiumKit.webp" width="64" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6502914189?pt=549314&ct=github.com&mt=8">
        <strong>FreemiumKit: In-App Purchases for Indies</strong>
      </a>
      <br />
      Simple In-App Purchases and Subscriptions: Automation, Paywalls, A/B Testing, Live Notifications, PPP, and more.
    </td>
    <td>iPhone, iPad, Mac, Vision</td>
  </tr>
  <tr>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6587583340?pt=549314&ct=github.com&mt=8">
        <img src="https://raw.githubusercontent.com/FlineDev/HandySwiftUI/main/Images/Apps/PleydiaOrganizer.webp" width="64" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6587583340?pt=549314&ct=github.com&mt=8">
        <strong>Pleydia Organizer: Movie & Series Renamer</strong>
      </a>
      <br />
      Simple, fast, and smart media management for your Movie, TV Show and Anime collection.
    </td>
    <td>Mac</td>
  </tr>
  <tr>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6480134993?pt=549314&ct=github.com&mt=8">
        <img src="https://raw.githubusercontent.com/FlineDev/HandySwiftUI/main/Images/Apps/FreelanceKit.webp" width="64" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6480134993?pt=549314&ct=github.com&mt=8">
        <strong>FreelanceKit: Project Time Tracking</strong>
      </a>
      <br />
      Simple & affordable time tracking with a native experience for all devices. iCloud sync & CSV export included.
    </td>
    <td>iPhone, iPad, Mac, Vision</td>
  </tr>
  <tr>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6472669260?pt=549314&ct=github.com&mt=8">
        <img src="https://raw.githubusercontent.com/FlineDev/HandySwiftUI/main/Images/Apps/CrossCraft.webp" width="64" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6472669260?pt=549314&ct=github.com&mt=8">
        <strong>CrossCraft: Custom Crosswords</strong>
      </a>
      <br />
      Create themed & personalized crosswords. Solve them yourself or share them to challenge others.
    </td>
    <td>iPhone, iPad, Mac, Vision</td>
  </tr>
  <tr>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6477829138?pt=549314&ct=github.com&mt=8">
        <img src="https://raw.githubusercontent.com/FlineDev/HandySwiftUI/main/Images/Apps/FocusBeats.webp" width="64" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6477829138?pt=549314&ct=github.com&mt=8">
        <strong>FocusBeats: Pomodoro + Music</strong>
      </a>
      <br />
      Deep Focus with proven Pomodoro method & select Apple Music playlists & themes. Automatically pauses music during breaks.
    </td>
    <td>iPhone, iPad, Mac, Vision</td>
  </tr>
  <tr>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6478062053?pt=549314&ct=github.com&mt=8">
        <img src="https://raw.githubusercontent.com/FlineDev/HandySwiftUI/main/Images/Apps/Posters.webp" width="64" />
      </a>
    </td>
    <td>
      <a href="https://apps.apple.com/app/apple-store/id6478062053?pt=549314&ct=github.com&mt=8">
        <strong>Posters: Discover Movies at Home</strong>
      </a>
      <br />
      Auto-updating & interactive posters for your home with trailers, showtimes, and links to streaming services.
    </td>
    <td>Vision</td>
  </tr>
</table>
