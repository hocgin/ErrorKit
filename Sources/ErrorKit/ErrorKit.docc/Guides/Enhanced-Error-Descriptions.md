# Enhanced Error Descriptions

Transform cryptic system errors into clear, actionable messages with better descriptions.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "EnhancedDescriptions")
}

## Highlights

System errors from Apple frameworks often return messages that are too technical or vague to be helpful. ErrorKit provides enhanced, user-friendly descriptions for these errors through the `userFriendlyMessage(for:)` function.

### The Problem with System Error Messages

When working with system APIs, errors often have unclear or technical messages:

```swift
do {
    let data = try Data(contentsOf: URL(string: "https://example.com/missing")!)
} catch {
    print(error.localizedDescription)
    // Output: "The file couldn't be opened because it doesn't exist."
    // Would be better as: "The requested resource at example.com/missing could not be found."
}
```

These messages may confuse users or fail to provide actionable information about how to resolve the issue.

### The Solution: Enhanced Error Descriptions

ErrorKit's `userFriendlyMessage(for:)` function provides improved error messages:

```swift
do {
    let data = try Data(contentsOf: URL(string: "https://example.com/missing")!)
} catch {
    print(ErrorKit.userFriendlyMessage(for: error))
    // Output: "The requested resource at example.com/missing could not be found. Please check that the URL is correct."
}
```

This function works with any error type, including system errors and your own custom errors. It maintains all the benefits of your custom `Throwable` types while enhancing system errors with more helpful messages.

### Comprehensive Error Domain Coverage

ErrorKit provides enhanced messages for errors from a wide range of system frameworks and domains:

#### Foundation Domain
- File operations (`fileExists`, `createDirectory`, etc.)
- URL loading and networking errors
- JSON and data parsing issues
- User defaults and preferences
- Bundle and resource loading

#### CoreData Domain
- Model validation errors
- Persistence and migration issues
- Fetch request execution errors
- Save and merge conflicts

#### MapKit and Location Domain
- Permission and authorization errors
- Geocoding failures
- Navigation and routing issues
- Region monitoring errors

#### Other Supported Domains
- CloudKit storage errors
- StoreKit purchase failures
- PhotoKit media access issues
- HealthKit data retrieval errors
- PassKit payment processing errors
- And many more system frameworks

The library's coverage grows with each release, focusing on the most common error scenarios that developers encounter. When you encounter a system error type that doesn't yet have an enhanced description, you can contribute your own (see Contributing section below).

### Works Seamlessly with Throwable

The `userFriendlyMessage(for:)` function integrates perfectly with ErrorKit's `Throwable` protocol:

```swift
do {
    try riskyOperation()
} catch {
    // Works with both custom Throwable errors and system errors
    showAlert(message: ErrorKit.userFriendlyMessage(for: error))
}
```

If the error already conforms to `Throwable`, its `userFriendlyMessage` is used. For system errors, ErrorKit provides an enhanced description from its community-maintained collection.

### Localization Support

All enhanced error messages are fully localized, ensuring users receive messages in their preferred language where available. ErrorKit uses standard localization patterns, making it easy to contribute translations for new languages.

### Contributing New Descriptions

The enhanced error description system is designed to be community-driven. Here's how you can contribute:

1. **Identify Cryptic Messages**: When you encounter a system error with a poor default message, note the error domain and code.

2. **Craft a Better Message**: Create a clearer, more actionable alternative that follows these guidelines:
   - Be specific about what went wrong
   - Use plain language, not technical jargon
   - Suggest a possible resolution when appropriate
   - Keep messages concise but informative

3. **Submit a Pull Request**: Add your improved description to the appropriate error domain file in the project. The PR should include:
   - The original error's domain and code
   - Your enhanced message
   - A small test case demonstrating the error (if possible)
   - Any relevant localization strings

4. **Testing Your Change**: Use the `ErrorKit.userFriendlyMessage(for:)` function with the error you're enhancing to verify your change works properly.

Example contribution for a network error:

```swift
// In NetworkErrorDescriptions.swift
static func enhancedDescription(for error: NSError) -> String? {
    switch (error.domain, error.code) {
    // Existing cases...
    
    // New contribution
    case (NSURLErrorDomain, NSURLErrorCannotDecodeRawData):
        return String.localized(
            key: "EnhancedErrors.Network.cannotDecodeRawData",
            defaultValue: "The data received from the server is corrupted or in an unsupported format. Try again or contact support if the issue persists."
        )
    
    // More cases...
    }
}
```

By contributing enhanced descriptions, you help improve error handling for the entire Swift developer community.

## Topics

### Essentials

- ``ErrorKit/userFriendlyMessage(for:)``

### Domain-Specific Handlers

- ``ErrorKit/userFriendlyFoundationMessage(for:)``
- ``ErrorKit/userFriendlyCoreDataMessage(for:)``
- ``ErrorKit/userFriendlyMapKitMessage(for:)``
- ``ErrorKit/userFriendlyCloudKitMessage(for:)``
- ``ErrorKit/userFriendlyStoreKitMessage(for:)``
