# User Feedback with Logs

Simplify bug reports with automatic log collection from Apple's unified logging system.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "UserFeedbackWithLogs")
}

## Highlights

When users encounter issues in your app, getting enough context to diagnose the problem is crucial. ErrorKit makes it simple to add diagnostic log collection to your app, providing valuable context for bug reports and support requests.

### The Challenge of User Feedback

When users report problems, they often lack the technical knowledge to provide the necessary details:
- They don't know what information you need to diagnose the issue
- They can't easily access system logs or technical details
- They may struggle to reproduce complex issues on demand
- The steps they describe might be incomplete or unclear

Without proper context, developers face significant challenges:
- Time wasted in back-and-forth communications asking for more information
- Difficulty reproducing issues that occur only on specific devices or configurations
- Inability to diagnose intermittent problems that happen infrequently
- Frustration for both users and developers as issues remain unresolved

### The Power of System Logs

ErrorKit leverages Apple's unified logging system (`OSLog`/`Logger`) to collect valuable diagnostic information. If you're not already using structured logging, here's a quick introduction:

```swift
import OSLog

// Create a logger - optionally with subsystem and category
let logger = Logger()
// or
let networkLogger = Logger(subsystem: "com.yourapp", category: "networking")

// Log at appropriate levels
logger.trace("Very detailed tracing info")            // Alias for debug
logger.debug("Detailed connection info")              // Development debugging
logger.info("User tapped submit button")              // General information
logger.notice("Profile successfully loaded")          // Important events
logger.warning("Low disk space detected")             // Alias for error
logger.error("Failed to load user data")              // Errors that should be fixed
logger.critical("Payment processing failed")          // Critical issues (alias for fault)
logger.fault("Database corruption detected")          // System failures

// Format values and control privacy
logger.info("User \(userId, privacy: .private) logged in from \(ipAddress, privacy: .public)")
logger.debug("Memory usage: \(bytes, format: .byteCount)")
```

Apple's logging system offers significant advantages over `print()` statements:
- Privacy controls for sensitive data
- Efficient performance with minimal overhead
- Log levels for filtering information
- System-wide integration
- Persistence across app launches
- Console integration for debugging

### Comprehensive Log Collection

A key advantage of ErrorKit's log collection is that it captures not just your app's logs, but also relevant logs from:

1. **Third-party frameworks** that use Apple's unified logging system
2. **System components** your app interacts with (networking, file system, etc.)
3. **Background processes** related to your app's functionality

This gives you a complete picture of what was happening in and around your app when the issue occurred, not just the logs you explicitly added. This comprehensive context is often crucial for diagnosing complex issues that involve multiple components.

### Creating a Feedback Button

The easiest way to implement error reporting is with the `.mailComposer` SwiftUI modifier:

```swift
struct ContentView: View {
    @State private var showMailComposer = false
    
    var body: some View {
        Form {
            // Your app content
            
            Button("Report a Problem") {
                showMailComposer = true
            }
            .mailComposer(
                isPresented: $showMailComposer,
                recipient: "support@yourapp.com",
                subject: "Bug Report",
                messageBody: """
                   Please describe what happened:
                   
                   
                   
                   ----------------------------------
                   Device: \(UIDevice.current.model)
                   iOS: \(UIDevice.current.systemVersion)
                   App version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                   """,
                attachments: [
                    try? ErrorKit.logAttachment(ofLast: .minutes(30))
                ]
            )
        }
    }
}
```

This creates a simple "Report a Problem" button that:
1. Opens a pre-filled email composer
2. Includes useful device and app information
3. Automatically attaches recent system logs
4. Provides space for the user to describe the issue

### Controlling Log Collection

ErrorKit offers several options for controlling log collection:

```swift
// Collect logs from the last 30 minutes with notice level or higher
try ErrorKit.logAttachment(ofLast: .minutes(30), minLevel: .notice)

// Collect logs from the last hour with error level or higher (fewer, more important logs)
try ErrorKit.logAttachment(ofLast: .hours(1), minLevel: .error)

// Collect logs from the last 5 minutes with debug level or higher (very detailed)
try ErrorKit.logAttachment(ofLast: .minutes(5), minLevel: .debug)
```

The `minLevel` parameter lets you control how verbose the logs are:
- `.debug`: All logs (very verbose)
- `.info`: Informational logs and above
- `.notice`: Notable events (default)
- `.error`: Only errors and faults
- `.fault`: Only critical errors

### Alternative Methods

If you need more control over log handling, ErrorKit offers additional approaches:

#### Getting Log Data Directly

For sending logs to your own backend or processing them in-app:

```swift
let logData = try ErrorKit.loggedData(
    ofLast: .minutes(10),
    minLevel: .notice
)

// Use the data with your custom reporting system
analyticsService.sendLogs(data: logData)
```

#### Exporting to a Temporary File

For sharing logs via other mechanisms:

```swift
let logFileURL = try ErrorKit.exportLogFile(
    ofLast: .hours(1),
    minLevel: .error
)

// Share the log file
let activityVC = UIActivityViewController(
    activityItems: [logFileURL],
    applicationActivities: nil
)
present(activityVC, animated: true)
```

### Transforming the Support Experience

Implementing a feedback button with automatic log collection transforms the support experience for both users and developers:

#### For Users:
- **Simplified Reporting**: Submit feedback with a single tap, no technical knowledge required
- **No Technical Questions**: Avoid frustrating back-and-forth asking for technical details
- **Faster Resolution**: Issues can be diagnosed and fixed more quickly
- **Better Experience**: Shows users you take their problems seriously with professional tools

#### For Developers:
- **Complete Context**: See exactly what was happening when the issue occurred
- **Reduced Support Burden**: Less time spent asking for additional information
- **Better Reproduction**: More reliable reproduction steps based on log data
- **Efficient Debugging**: Quickly identify patterns in error reports
- **Developer Sanity**: Stop trying to reproduce issues with insufficient information

The investment in proper log collection pays dividends in reduced support costs, faster issue resolution, and improved user satisfaction.

### Best Practices for Logging

To maximize the value of ErrorKit's log collection:

1. **Use Apple's Logger Instead of Print**:
   ```swift
   // Instead of:
   print("User logged in: \(username)")
   
   // Use:
   Logger().info("User logged in: \(username, privacy: .private)")
   ```

2. **Choose Appropriate Log Levels**:
   - `.debug` for developer details that are only needed during development
   - `.info` for general tracking of normal app flow
   - `.notice` for important events users would care about
   - `.error` for problems that need fixing but don't prevent core functionality
   - `.fault` for critical issues that break core functionality

3. **Include Context in Logs**:
   ```swift
   // Instead of:
   Logger().error("Failed to load")
   
   // Use:
   Logger().error("Failed to load document \(documentId): \(error.localizedDescription)")
   ```

4. **Protect Sensitive Information**:
   ```swift
   Logger().info("Processing payment for user \(userId, privacy: .private)")
   ```

By implementing these best practices along with ErrorKit's log collection, you create a robust system for gathering the context needed to diagnose and fix issues efficiently.

## Topics

### Essentials

- ``ErrorKit/logAttachment(ofLast:minLevel:filename:)``
- ``ErrorKit/loggedData(ofLast:minLevel:)``
- ``ErrorKit/exportLogFile(ofLast:minLevel:)``

### Helper Types

- ``MailAttachment``
- ``Duration/timeInterval``
- ``Duration/minutes(_:)``
- ``Duration/hours(_:)``
