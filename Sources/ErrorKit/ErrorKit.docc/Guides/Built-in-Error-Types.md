# Built-in Error Types

Stop reinventing common error types with ready-to-use standardized errors.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "BuiltInErrorTypes")
}

## Highlights

ErrorKit provides pre-defined error types for common scenarios, reducing boilerplate and providing consistent error handling patterns across your projects.

### Why Built-in Types?

Most applications deal with similar error categories – database issues, network problems, file access errors, and validation failures. Defining these types repeatedly leads to:
- Duplicate work implementing similar error cases
- Inconsistent error handling patterns
- Lack of standardized error messages

ErrorKit's built-in types offer several advantages:
- **Quick Start** – Begin with well-structured error handling without defining custom types
- **Consistency** – Use standardized error cases and messages across your codebase
- **Flexibility** – Easily transition to custom error types when you need more specific cases
- **Discoverability** – Clear naming conventions make it easy to find the right error type
- **Localization** – All error messages are pre-localized and user-friendly

### Available Error Types

ErrorKit provides a comprehensive set of built-in error types, each designed to address common error scenarios in Swift applications:

- **DatabaseError** – For database connection and query issues
- **FileError** – For file system operations
- **NetworkError** – For network requests and API communications
- **ValidationError** – For input validation
- **StateError** – For state management and transitions
- **OperationError** – For operation execution issues
- **PermissionError** – For permission-related concerns
- **ParsingError** – For data parsing problems
- **GenericError** – For quick custom error cases

Each of these types conforms to both `Throwable` and `Catching` protocols, providing seamless integration with [typed throws](Typed-Throws-and-Error-Nesting) and the [error chain debugging](Error-Chain-Debugging) system.

### Ecosystem Impact

As more Swift packages adopt these standardized error types, a powerful network effect emerges:

- **Cross-package Communication** – Libraries can throw standard error types that applications understand and can handle intelligently
- **Smart Error Handling** – Instead of just showing error messages, apps can provide specific UI or recovery actions for known error types
- **Unified Error Experience** – Users experience consistent error handling patterns across different features and modules
- **Reduced Learning Curve** – Developers can learn one set of error patterns that work across multiple packages
- **Better Testing** – Standardized error types mean standardized testing patterns

This standardization creates a more cohesive error handling experience throughout the Swift ecosystem, similar to how `Codable` created a standard for data serialization.

## Database Error Handling

The `DatabaseError` type addresses common database operation failures. Here's how you might use it:

```swift
func fetchUserData(userId: String) throws(DatabaseError) {
    guard isConnected else {
        throw DatabaseError.connectionFailed
    }
    
    guard let user = database.findUser(id: userId) else {
        throw DatabaseError.recordNotFound(entity: "User", identifier: userId)
    }
    
    do {
        return try processUserData(user)
    } catch {
        // Automatically wrap any other errors
        throw DatabaseError.caught(error)
    }
}
```

`DatabaseError` includes the following cases:
- `.connectionFailed` – Unable to connect to the database
- `.operationFailed(context:)` – Query execution failed
- `.recordNotFound(entity:identifier:)` – Requested record doesn't exist
- `.caught(Error)` – For wrapping other errors
- `.generic(userFriendlyMessage:)` – For custom one-off scenarios

### Core Data Example

For context, here's how you might handle Core Data errors without ErrorKit:

```swift
func updateProfile(name: String, bio: String) {
    do {
        try context.performChanges {
            user.name = name
            user.bio = bio
            try context.save()
        }
    } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSValidationError {
        // Complex error checking with domain and code
        showAlert(message: "Invalid data provided.")
    } catch {
        showAlert(message: "Unknown error occurred.")
    }
}
```

And here's the same function using ErrorKit:

```swift
func updateProfile(name: String, bio: String) {
    do {
        try context.performChanges {
            user.name = name
            user.bio = bio
            try context.save()
        }
    } catch {
        // Simpler error handling with better messages
        showAlert(message: ErrorKit.userFriendlyMessage(for: error))
    }
}
```

The advantage is clear: ErrorKit eliminates the need for complex error domain/code checking while providing more descriptive error messages to users.

## Network Error Handling

The `NetworkError` type addresses common networking issues. Here's an example:

```swift
func fetchProfileData() async throws(NetworkError) {
    guard isNetworkReachable else {
        throw NetworkError.noInternet
    }
    
    let (data, response) = try await URLSession.shared.data(from: profileURL)
    
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.badRequest(code: 0, message: "Invalid response")
    }
    
    guard httpResponse.statusCode == 200 else {
        throw NetworkError.serverError(
            code: httpResponse.statusCode,
            message: String(data: data, encoding: .utf8)
        )
    }
    
    guard let profile = try? JSONDecoder().decode(Profile.self, from: data) else {
        throw NetworkError.decodingFailure
    }
    
    return profile
}
```

`NetworkError` includes the following cases:
- `.noInternet` – No network connection available
- `.timeout` – Request took too long to complete
- `.badRequest(code:message:)` – Client-side HTTP errors (400-499)
- `.serverError(code:message:)` – Server-side HTTP errors (500-599)
- `.decodingFailure` – Error parsing the response data
- `.caught(Error)` – For wrapping other errors
- `.generic(userFriendlyMessage:)` – For custom one-off scenarios

### Custom Error Handling

NetworkError enables enhanced user experiences through targeted handling:

```swift
func fetchData() async {
    do {
        data = try await fetchProfileData()
        state = .loaded
    } catch {
        state = .error
        
        // Specific handling for different network errors
        switch error {
        case NetworkError.noInternet, NetworkError.timeout:
            // Show offline mode with cached data + refresh button
            showOfflineView(with: cachedData)
            
        case let networkError as URLSessionError where networkError == .unauthorized:
            // Trigger re-authentication flow
            showAuthenticationPrompt()
            
        case let NetworkError.serverError(code, _) where code >= 500:
            // Show maintenance message for server errors
            showServerMaintenanceMessage()
            
        default:
            // Default error handling
            showErrorAlert(message: ErrorKit.userFriendlyMessage(for: error))
        }
    }
}
```

## File System Error Handling

The `FileError` type addresses common file operations issues:

```swift
func loadConfiguration() throws(FileError) {
    let configFile = "config.json"
    guard FileManager.default.fileExists(atPath: configPath) else {
        throw FileError.fileNotFound(fileName: configFile)
    }
    
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
        return try JSONDecoder().decode(Configuration.self, from: data)
    } catch let error as DecodingError {
        throw FileError.readFailed(fileName: configFile)
    } catch {
        throw FileError.caught(error)
    }
}
```

`FileError` includes the following cases:
- `.fileNotFound(fileName:)` – File doesn't exist
- `.readFailed(fileName:)` – Error reading from file
- `.writeFailed(fileName:)` – Error writing to file
- `.caught(Error)` – For wrapping other errors
- `.generic(userFriendlyMessage:)` – For custom one-off scenarios

## Validation Error Handling

The `ValidationError` type simplifies input validation:

```swift
func validateRegistration(username: String, email: String, password: String) throws(ValidationError) {
    guard !username.isEmpty else {
        throw ValidationError.missingField(field: "Username")
    }
    
    guard username.count <= 30 else {
        throw ValidationError.inputTooLong(field: "Username", maxLength: 30)
    }
    
    guard isValidEmail(email) else {
        throw ValidationError.invalidInput(field: "Email")
    }
    
    return RegistrationData(username: username, email: email, password: password)
}
```

`ValidationError` includes the following cases:
- `.invalidInput(field:)` – Input doesn't meet format requirements
- `.missingField(field:)` – Required field is empty
- `.inputTooLong(field:maxLength:)` – Input exceeds maximum length
- `.caught(Error)` – For wrapping other errors
- `.generic(userFriendlyMessage:)` – For custom one-off scenarios

## Additional Error Types

### Permission Error Handling

The `PermissionError` type addresses authorization issues:

```swift
func requestLocationAccess() throws(PermissionError) {
    switch locationManager.authorizationStatus {
    case .notDetermined:
        throw PermissionError.notDetermined(permission: "Location")
    case .restricted:
        throw PermissionError.restricted(permission: "Location")
    case .denied:
        throw PermissionError.denied(permission: "Location")
    case .authorizedAlways, .authorizedWhenInUse:
        return // Permission granted
    @unknown default:
        throw PermissionError.generic(userFriendlyMessage: "Unknown location permission status")
    }
}
```

### State Error Handling

The `StateError` type manages invalid state transitions:

```swift
func finalizeOrder(_ order: Order) throws(StateError) {
    guard order.status == .verified else {
        throw StateError.invalidState(description: "Order must be verified")
    }
    
    guard !order.isFinalized else {
        throw StateError.alreadyFinalized
    }
    
    guard order.items.count > 0 else {
        throw StateError.preconditionFailed(description: "Order must have at least one item")
    }
    
    // Finalize order
}
```

### Operation Error Handling

The `OperationError` type handles execution failures:

```swift
func executeOperation() async throws(OperationError) {
    guard !Task.isCancelled else {
        throw OperationError.canceled
    }
    
    guard dependenciesSatisfied() else {
        throw OperationError.dependencyFailed(dependency: "Data Initialization")
    }
    
    // Execute operation
}
```

### Parsing Error Handling

The `ParsingError` type addresses data parsing issues:

```swift
func parseUserData(from json: Data) throws(ParsingError) {
    guard !json.isEmpty else {
        throw ParsingError.invalidInput(input: "Empty JSON data")
    }
    
    do {
        let decoder = JSONDecoder()
        return try decoder.decode(UserData.self, from: json)
    } catch {
        throw ParsingError.caught(error)
    }
}
```

## Generic Error Handling

For one-off errors without defining custom types, use `GenericError`:

```swift
func quickOperation() throws {
    guard condition else {
        throw GenericError(userFriendlyMessage: "The operation couldn't be completed due to invalid state.")
    }
    
    try GenericError.catch {
        try riskyOperation()
    }
}
```

`GenericError` is perfect during rapid development or for one-off error cases that don't justify creating a full custom type. You can always replace it with a more specific error type later when needed.

## Flexible Error Handling with Generic Cases

All built-in error types include a `.generic(userFriendlyMessage:)` case for edge cases:

```swift
func handleSpecialCase() throws(DatabaseError) {
    guard specialCondition else {
        throw DatabaseError.generic(userFriendlyMessage: "Database is in maintenance mode until 10 PM.")
    }
    // Special case handling
}
```

This allows you to use the specific error type for categorization while providing a custom message for unusual situations.

## Contributing New Error Types

If you find yourself:
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

## Topics

### Essentials

- ``DatabaseError``
- ``FileError``
- ``GenericError``
- ``NetworkError``
- ``OperationError``
- ``ParsingError``
- ``PermissionError``
- ``StateError``
- ``ValidationError``

### Continue Reading

- <doc:User-Feedback-with-Logs>
