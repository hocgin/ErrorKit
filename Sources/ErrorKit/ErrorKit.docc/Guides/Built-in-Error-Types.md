# Built-in Error Types

Stop reinventing common error types with ready-to-use standardized errors.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "ErrorTypes")
}

## Highlights

ErrorKit provides pre-defined error types for common scenarios, reducing boilerplate and providing consistent error handling patterns across your projects.

### Why Built-in Types?

Most applications deal with similar error categories – database issues, network problems, file access errors, and validation failures. Defining these types repeatedly leads to:
- Duplicate work implementing similar error cases
- Inconsistent error handling patterns
- Lack of standardized error messages

ErrorKit's built-in types offer several advantages:
- **Quick Start**: Begin with well-structured error handling without defining custom types
- **Consistency**: Use standardized error cases and messages across your codebase
- **Flexibility**: Easily transition to custom error types when you need more specific cases
- **Discoverability**: Clear naming conventions make it easy to find the right error type
- **Localization**: All error messages are pre-localized and user-friendly

### Ecosystem Impact

As more Swift packages adopt these standardized error types, a powerful network effect emerges:

- **Cross-package Communication**: Libraries can throw standard error types that applications understand and can handle intelligently
- **Smart Error Handling**: Instead of just showing error messages, apps can provide specific UI or recovery actions for known error types
- **Unified Error Experience**: Users experience consistent error handling patterns across different features and modules
- **Reduced Learning Curve**: Developers can learn one set of error patterns that work across multiple packages
- **Better Testing**: Standardized error types mean standardized testing patterns

This standardization creates a more cohesive error handling experience throughout the Swift ecosystem, similar to how `Codable` created a standard for data serialization.

### DatabaseError

For database operations and queries:

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

`DatabaseError` includes cases for common database failures:
- `.connectionFailed` - Unable to connect to the database
- `.operationFailed(context:)` - Query execution failed
- `.recordNotFound(entity:identifier:)` - Requested record doesn't exist
- `.caught(Error)` - For wrapping other errors
- `.generic(userFriendlyMessage:)` - For custom one-off scenarios

#### Real-world Example

In a typical scenario with Core Data or SQLite:

```swift
func updateProfile(name: String, bio: String) {
    do {
        try context.performChanges {
            user.name = name
            user.bio = bio
            try context.save()
        }
    } catch let error as NSError where error.domain == NSCocoaErrorDomain && error.code == NSValidationError {
        // Standard approach - messy error handling
        showAlert(message: "Invalid data provided.")
    } catch {
        showAlert(message: "Unknown error occurred.")
    }
}
```

With ErrorKit:

```swift
func updateProfile(name: String, bio: String) {
    do {
        try context.performChanges {
            user.name = name
            user.bio = bio
            try context.save()
        }
    } catch {
        // Clear, standardized error handling
        showAlert(message: ErrorKit.userFriendlyMessage(for: error))
    }
}
```

### NetworkError

For network requests and API communications:

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

`NetworkError` includes cases for common network issues:
- `.noInternet` - No network connection available
- `.timeout` - Request took too long to complete
- `.badRequest(code:message:)` - Client-side HTTP errors (400-499)
- `.serverError(code:message:)` - Server-side HTTP errors (500-599)
- `.decodingFailure` - Error parsing the response data
- `.caught(Error)` - For wrapping other errors

#### Enhanced User Experience

With typed NetworkError, you can provide custom handling for different error cases:

```swift
func fetchData() async {
    do {
        data = try await fetchProfileData()
        state = .loaded
    } catch {
        state = .error
        
        // Enhanced UX through specific error handling
        switch error {
        case NetworkError.noInternet, NetworkError.timeout:
            // Show offline mode with cached data + refresh button
            showOfflineView(with: cachedData)
            
        case NetworkError.unauthorized:
            // Trigger re-authentication flow
            showAuthenticationPrompt()
            
        case NetworkError.serverError(let code, _) where code >= 500:
            // Show maintenance message for server errors
            showServerMaintenanceMessage()
            
        default:
            // Default error handling
            showErrorAlert(message: ErrorKit.userFriendlyMessage(for: error))
        }
    }
}
```

### FileError

For file system operations:

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

`FileError` includes cases for common file issues:
- `.fileNotFound(fileName:)` - File doesn't exist
- `.readFailed(fileName:)` - Error reading from file
- `.writeFailed(fileName:)` - Error writing to file
- `.caught(Error)` - For wrapping other errors

### ValidationError

For input validation:

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

`ValidationError` includes cases for common validation issues:
- `.invalidInput(field:)` - Input doesn't meet format requirements
- `.missingField(field:)` - Required field is empty
- `.inputTooLong(field:maxLength:)` - Input exceeds maximum length
- `.caught(Error)` - For wrapping other errors

### Other Built-in Types

ErrorKit includes additional error types for common scenarios:

#### PermissionError

For permission-related issues:

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

#### StateError

For invalid state transitions or conditions:

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

#### OperationError

For operation failures, cancellations, etc.:

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

### Quick Error Creation with GenericError

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

### Generic Case for Edge Cases

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

### Contributing New Error Types

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
