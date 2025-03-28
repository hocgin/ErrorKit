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

- Duplication of effort across projects
- Inconsistent error messages and patterns
- Lack of standardized error handling

ErrorKit's built-in types address these issues with a comprehensive collection of error enums that conform to both `Throwable` and `Catching`.

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

`GenericError` is perfect during rapid development or for one-off error cases that don't justify creating a full custom type.

### Other Built-in Types

ErrorKit includes additional error types for common scenarios:

- **PermissionError**: For permission-related issues (denied, restricted, etc.)
- **StateError**: For invalid state transitions or conditions
- **OperationError**: For operation failures, cancellations, etc.

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
