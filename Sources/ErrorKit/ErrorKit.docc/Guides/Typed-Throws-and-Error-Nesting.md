# Typed Throws and Error Nesting

Making Swift 6's typed throws practical with seamless error propagation across layers.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "TypedThrows")
}

## Highlights

Swift 6 introduces typed throws (`throws(ErrorType)`) for stronger type safety in error handling. ErrorKit makes this powerful feature practical by solving the challenge of error propagation across layers with the `Catching` protocol.

### Understanding Typed Throws

Typed throws let you declare exactly which error types a function can throw:

```swift
func processFile() throws(FileError) {
    // This function can only throw FileError
}
```

This enables compile-time verification of error handling:

```swift
do {
    try processFile()
} catch FileError.fileNotFound {
    // Handle specific case
} catch FileError.readFailed {
    // Handle another specific case
}
// No need for a catch-all since all possibilities are covered
```

### The Problem: Error Propagation

While typed throws improves type safety, it creates a challenge when propagating errors through multiple layers of an application. Without ErrorKit, you'd need to manually wrap errors at each layer:

```swift
enum ProfileError: Error {
    case validationFailed(field: String)
    case databaseError(DatabaseError)    // Wrapper case needed for database errors
    case networkError(NetworkError)      // Another wrapper for network errors
}

func loadProfile(id: String) throws(ProfileError) {
    do {
        try database.loadUser(id)
    } catch let error as DatabaseError {
        throw ProfileError.databaseError(error) // Manual wrapping
    }
}
```

This approach requires:
1. Creating explicit wrapper cases for each possible error type
2. Writing repetitive do-catch blocks for manual error conversion
3. Maintaining this wrapping code as your error types evolve

### The Solution: Catching Protocol

ErrorKit's `Catching` protocol provides a clean solution:

```swift
enum ProfileError: Throwable, Catching {
    case validationFailed(field: String)
    case caught(Error)  // Single case handles all nested errors
    
    var userFriendlyMessage: String { /* ... */ }
}

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
    
    return userData
}
```

The `catch` function automatically wraps any errors thrown in its closure into the `caught` case, preserving both type safety and the error's original information.

### How Catching Works

The `Catching` protocol:

1. Requires a single `caught(Error)` case for storing wrapped errors
2. Provides a static `catch` function for automatic error wrapping
3. Preserves return values from the wrapped operation
4. Maintains type safety with typed throws

### Error Chain Debugging

When using `Throwable` with the `Catching` protocol, you gain powerful debugging capabilities through ErrorKit's error chain visualization:

```swift
do {
    try await updateUserProfile()
} catch {
    print(ErrorKit.errorChainDescription(for: error))
    
    // Output:
    // ProfileError
    // └─ DatabaseError
    //    └─ FileError.notFound(path: "/Users/data.db")
    //       └─ userFriendlyMessage: "Could not find database file."
}
```

This hierarchical view shows:
1. Where the error originated (FileError)
2. How it was wrapped (DatabaseError → ProfileError)
3. What exactly went wrong (file not found)
4. The user-friendly message that would be shown to users

### Error Analytics with Grouping IDs

For tracking error patterns in analytics, ErrorKit provides `groupingID(for:)`:

```swift
func trackError(_ error: Error) {
    let groupID = ErrorKit.groupingID(for: error) // e.g. "3f9d2a"
    
    Analytics.track(
        event: "error_occurred",
        properties: [
            "error_group": groupID,
            "error_details": ErrorKit.errorChainDescription(for: error)
        ]
    )
}
```

The grouping ID generates the same identifier for errors that share the same type hierarchy and enum cases, ignoring dynamic parameters and localized messages. This helps you identify common error patterns and prioritize fixes effectively.

## Topics

### Essentials

- ``Catching``
- ``Catching/catch(_:)``

### Error Chain Analysis

- ``ErrorKit/errorChainDescription(for:)``
- ``ErrorKit/groupingID(for:)``

### System Overloads

- ``FileManager/throwableCreateDirectory(at:withIntermediateDirectories:attributes:)``
- ``FileManager/throwableRemoveItem(at:)``
- ``URLSession/throwableData(for:)``
- ``URLSession/throwableData(from:)``
