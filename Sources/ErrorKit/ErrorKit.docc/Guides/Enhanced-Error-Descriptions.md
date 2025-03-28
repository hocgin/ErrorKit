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

### Community-Maintained Error Descriptions

The enhanced error messages are maintained by the developer community. ErrorKit includes a growing collection of improved descriptions for common error domains:

- Foundation (file operations, network requests)
- CoreData (database operations)
- MapKit (location and mapping errors)
- And many more system frameworks

All messages are fully localized, ensuring users receive them in their preferred language where available.

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

### Contributing New Descriptions

You can help improve ErrorKit by contributing better error descriptions:

1. Identify a system error with a poor default message
2. Create a clearer, more actionable alternative
3. Submit a pull request to add your improvement

Great error messages should:
- Be specific about what went wrong
- Use plain language, not technical jargon
- Suggest a resolution when possible
- Be concise but informative

## Topics

### Essentials

- ``ErrorKit/userFriendlyMessage(for:)``

### Internal Helpers

- ``ErrorKit/userFriendlyFoundationMessage(for:)``
- ``ErrorKit/userFriendlyCoreDataMessage(for:)``
- ``ErrorKit/userFriendlyMapKitMessage(for:)``
