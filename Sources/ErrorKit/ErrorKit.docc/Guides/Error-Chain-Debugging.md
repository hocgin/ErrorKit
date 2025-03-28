# Error Chain Debugging

Trace the complete path of errors through your application with rich hierarchical debugging.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "ErrorChainDebugging")
}

## Highlights

One of the most challenging aspects of error handling in Swift is understanding exactly where an error originated, especially when using error wrapping across multiple layers of an application. ErrorKit solves this with powerful debugging tools that help you understand the complete error chain.

### The Problem with Traditional Error Logging

When logging errors in Swift, you typically lose context about how an error propagated through your application:

```swift
} catch {
    // 😕 Only shows the leaf error with no chain information
    Logger().error("Error occurred: \(error)")
    
    // 😕 Shows a better message but still no error chain
    Logger().error("Error: \(ErrorKit.userFriendlyMessage(for: error))")
    // Output: "Could not find database file."
}
```

This makes it difficult to:
- Understand which module or layer originally threw the error
- Trace the error's path through your application
- Group similar errors for analysis
- Prioritize which errors to fix first

### Solution: Error Chain Description

ErrorKit's `errorChainDescription(for:)` function provides a comprehensive view of the entire error chain, showing you exactly how an error propagated through your application:

```swift
do {
    try await updateUserProfile()
} catch {
    // 🎯 Always use this for debug logging
    Logger().error("\(ErrorKit.errorChainDescription(for: error))")
    
    // Output shows the complete chain:
    // ProfileError
    // └─ DatabaseError
    //    └─ FileError.notFound(path: "/Users/data.db")
    //       └─ userFriendlyMessage: "Could not find database file."
}
```

This hierarchical view tells you:
1. Where the error originated (FileError)
2. How it was wrapped (DatabaseError → ProfileError)
3. What exactly went wrong (file not found)
4. The user-friendly message (reported to users)

For errors conforming to the `Catching` protocol, you get the complete error wrapping chain. This is why it's important for your own error types and any Swift packages you develop to adopt both `Throwable` and `Catching` - it not only makes them work better with typed throws but also enables automatic extraction of the full error chain.

Even for errors that don't conform to `Catching`, you still get valuable information since most Swift errors are enums. The error chain description will show you the exact enum case (e.g., `FileError.notFound`), making it easy to search your codebase for the error's origin. This is much better than the default cryptic message you get for enum cases when using `localizedDescription`.

### Error Analytics with Grouping IDs

To help prioritize which errors to fix, ErrorKit provides `groupingID(for:)` that generates stable identifiers for errors sharing the exact same type structure and enum cases:

```swift
struct ErrorTracker {
    static func log(_ error: Error) {
        // Get a stable ID that ignores dynamic parameters
        let groupID = ErrorKit.groupingID(for: error) // e.g. "3f9d2a"
        
        Analytics.track(
            event: "error_occurred",
            properties: [
                "error_group": groupID,
                "error_details": ErrorKit.errorChainDescription(for: error)
            ]
        )
    }
}
```

The grouping ID generates the same identifier for errors that have identical:
- Error type hierarchy
- Enum cases in the chain

But it ignores:
- Dynamic parameters (file paths, field names, etc.)
- User-friendly messages (which might be localized or dynamic)

For example, these errors have the same grouping ID since they differ only in their dynamic path parameters:
```swift
// Both generate groupID: "3f9d2a"
ProfileError
└─ DatabaseError
   └─ FileError.notFound(path: "/Users/john/data.db")
      └─ userFriendlyMessage: "Could not find database file."

ProfileError
└─ DatabaseError
   └─ FileError.notFound(path: "/Users/jane/backup.db")
      └─ userFriendlyMessage: "Die Backup-Datenbank konnte nicht gefunden werden."
```

This precise grouping allows you to:
- Track true error frequencies in analytics without noise from dynamic data
- Create meaningful charts of most common error patterns
- Make data-driven decisions about which errors to fix first
- Monitor error trends over time

### How Error Chain Description Works

Under the hood, `errorChainDescription(for:)` uses Swift's reflection capabilities to examine the structure of error objects:

1. It inspects the error using Swift's `Mirror` type
2. For errors conforming to `Catching`, it recursively traverses the error chain
3. For enum errors, it extracts case names and associated values
4. For struct or class errors, it includes type metadata
5. It formats all this information in a hierarchical tree structure
6. It appends the user-friendly message at each leaf node

This deep inspection reveals significantly more information than is available through standard error logging, particularly for complex error hierarchies.

### Implementation Details

Here's a simplified version of how the implementation works:

```swift
static func errorChainDescription(for error: Error) -> String {
    return Self.chainDescription(for: error, indent: "", enclosingType: type(of: error))
}

private static func chainDescription(for error: Error, indent: String, enclosingType: Any.Type?) -> String {
    let mirror = Mirror(reflecting: error)
    
    // For nested errors (Catching protocol)
    if let caughtError = mirror.children.first(where: { $0.label == "caught" })?.value as? Error {
        let currentErrorType = type(of: error)
        let nextIndent = indent + "   "
        return """
            \(currentErrorType)
            \(indent)└─ \(Self.chainDescription(for: caughtError, indent: nextIndent, enclosingType: type(of: caughtError)))
            """
    } else {
        // This is a leaf node
        let typeName = formatTypeName(error, enclosingType)
        return """
            \(typeName)
            \(indent)└─ userFriendlyMessage: \"\(Self.userFriendlyMessage(for: error))\"
            """
    }
}
```

This recursive approach ensures the complete error chain is captured, regardless of how deeply errors are nested.

### Use Cases and Benefits

Error chain debugging transforms Swift's error handling from a black box into a transparent system:

#### During Development
- **Pinpoint error origins**: Quickly identify where errors originate
- **Trace propagation paths**: See how errors flow through your application
- **Debug complex interactions**: Understand cross-module error handling
- **Identify wrapping patterns**: See which layers are adding context to errors

#### In Production
- **Analyze error patterns**: Group similar errors to find systemic issues
- **Set priorities**: Focus on the most common error paths first
- **Monitor trends**: Track error frequencies over time
- **Improve user experience**: Use insights to prevent common errors

#### For Support and Operations
- **Better diagnostics**: Include error chains in crash reports
- **Faster resolution**: Provide support with clear error context
- **Root cause analysis**: Trace issues to their source
- **Documentation**: Build a knowledge base of error patterns

### Integration with Logging Systems

To maximize the effectiveness of error chain debugging, integrate it with your logging system:

```swift
extension Logger {
    func logError(_ error: Error, file: String = #file, function: String = #function, line: Int = #line) {
        let errorChain = ErrorKit.errorChainDescription(for: error)
        self.error("\(errorChain, privacy: .public)", file: file, function: function, line: line)
    }
}

// Usage
do {
    try riskyOperation()
} catch {
    logger.logError(error)
}
```

For crash reporting and analytics systems, include both the error chain and grouping ID:

```swift
func reportCrash(_ error: Error) {
    CrashReporting.send(
        error: error,
        metadata: [
            "errorChain": ErrorKit.errorChainDescription(for: error),
            "errorGroup": ErrorKit.groupingID(for: error)
        ]
    )
}
```

### Best Practices

To get the most out of error chain debugging:

1. **Use `Catching` consistently**: Add `Catching` conformance to all your error types that might wrap other errors.

2. **Preserve context when wrapping errors**: Add meaningful information at each level without overwhelming users.

3. **Include error chain descriptions in logs**: Always use `errorChainDescription(for:)` when logging errors.

4. **Group errors for analytics**: Use `groupingID(for:)` to track error frequencies.

5. **Create visualizations**: Build dashboards showing most common error chains.

6. **Document error flows**: Use error chains to update documentation and onboard new team members.

### Summary

ErrorKit's debugging tools transform error handling from a black box into a transparent system. By combining `errorChainDescription` for debugging with `groupingID` for analytics, you get deep insight into error flows while maintaining the ability to track and prioritize issues effectively. This is particularly powerful when combined with ErrorKit's `Catching` protocol, creating a comprehensive system for error handling, debugging, and monitoring.

## Topics

### Essentials

- ``ErrorKit/errorChainDescription(for:)``
- ``ErrorKit/groupingID(for:)``

### Related Concepts

- ``Catching``
- ``Throwable``

### Continue Reading

- <doc:Built-in-Error-Types>
