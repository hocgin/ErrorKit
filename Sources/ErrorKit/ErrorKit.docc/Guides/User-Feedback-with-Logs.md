# User Feedback with Logs

Simplify bug reports with automatic log collection from Apple's unified logging system.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
   @PageImage(purpose: card, source: "UserFeedback")
}

## Highlights

When users encounter issues in your app, getting enough context to diagnose the problem is crucial. ErrorKit makes it simple to add diagnostic log collection to your app, providing valuable context for bug reports and support requests.

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

### Benefits of Automatic Log Collection

Implementing a feedback button with automatic log collection transforms the error reporting experience:

- **Better bug reports**: Get the context you need without asking users for technical details
- **Faster issue resolution**: See exactly what happened leading up to the problem
- **Lower support burden**: Reduce back-and-forth communications with users
- **User satisfaction**: Demonstrate that you take their problems seriously
- **Developer sanity**: Stop trying to reproduce issues with insufficient information

By making it easy for users to provide detailed logs with minimal effort, you'll get higher quality bug reports and be able to fix issues more efficiently.

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
