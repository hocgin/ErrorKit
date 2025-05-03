# Enhanced Error Descriptions

Transform cryptic system errors into clear, actionable messages with better descriptions.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "EnhancedDescriptions")
}

## Highlights

System errors from Apple frameworks often return messages that are too technical or vague to be helpful. ErrorKit provides enhanced, user-friendly descriptions for these errors through the `userFriendlyMessage(for:)` function.

### The Problem with System Error Messages

When working with system APIs, errors often have unclear or technical messages that may confuse users or fail to provide actionable information about how to resolve the issue.

### The Solution: Enhanced Error Descriptions

ErrorKit's `userFriendlyMessage(for:)` function provides improved error messages:

```swift
do {
    let url = URL(string: "https://example.com")!
    let _ = try Data(contentsOf: url)
} catch {
    // Instead of the default error message, get a more user-friendly one
    print(ErrorKit.userFriendlyMessage(for: error))
}
```

This function works with any error type, including system errors and your own custom errors. It maintains all the benefits of your custom `Throwable` types while enhancing system errors with more helpful messages.

### Error Domain Coverage

ErrorKit provides enhanced messages for errors from several system frameworks and domains:

#### Foundation Domain
- Network errors (URLError)
  - Connection issues
  - Timeouts
  - Host not found
- File operations (CocoaError)
  - File not found
  - Permission issues
  - Disk space errors
- System errors (POSIXError)
  - Disk space
  - Access permission
  - File descriptor issues

#### CoreData Domain
- Store save errors
- Validation errors
- Relationship errors
- Store compatibility issues
- Model validation errors

#### MapKit Domain
- Server failures
- Throttling errors
- Placemark not found
- Direction finding failures

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

If the error already conforms to `Throwable`, its `userFriendlyMessage` is used. For system errors, ErrorKit provides an enhanced description from its built-in mappers.

### Localization Support

All enhanced error messages are fully localized using the `String(localized:)` pattern, ensuring users receive messages in their preferred language where available.

### How It Works

The `userFriendlyMessage(for:)` function follows this process to determine the best error message:

1. If the error conforms to `Throwable`, it uses the error's own `userFriendlyMessage`
2. It queries registered error mappers to find enhanced descriptions
3. If the error conforms to `LocalizedError`, it combines its localized properties
4. As a fallback, it formats the NSError domain and code along with the standard `localizedDescription`

### Contributing New Descriptions

You can help improve ErrorKit by contributing better error descriptions for common error types:

1. Identify cryptic error messages from system frameworks
2. Implement domain-specific handlers or extend existing ones (see folder `ErrorMappers`)
3. Use clear, actionable language that helps users understand what went wrong
4. Include localization support for all messages (no need to actually localize, we'll take care)

Example contribution to handle a new error type:

```swift
// In FoundationErrorMapper.swift
case let jsonError as NSError where jsonError.domain == NSCocoaErrorDomain && jsonError.code == 3840:
    return String(localized: "The data couldn't be read because it isn't in the correct format.")
```

### Custom Error Mappers

While ErrorKit focuses on enhancing system and framework errors, you can also create custom mappers for any library:

```swift
enum MyLibraryErrorMapper: ErrorMapper {
    static func userFriendlyMessage(for error: Error) -> String? {
        switch error {
        case let libraryError as MyLibrary.Error:
            switch libraryError {
            case .apiKeyExpired:
                return String(localized: "API key expired. Please update your credentials.")
            default:
                return nil
            }
        default:
            return nil
        }
    }
}

// On app start:
ErrorKit.registerMapper(MyLibraryErrorMapper.self)
```

This extensibility allows the community to create mappers for 3rd-party libraries with known error issues.

## Topics

### Essentials

- ``ErrorKit/userFriendlyMessage(for:)``
- ``ErrorMapper``

### Built-in Mappers

- ``FoundationErrorMapper``
- ``CoreDataErrorMapper``
- ``MapKitErrorMapper``

### Continue Reading

- <doc:Typed-Throws-and-Error-Nesting>
