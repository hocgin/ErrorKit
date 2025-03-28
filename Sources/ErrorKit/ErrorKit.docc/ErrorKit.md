# ``ErrorKit``

Making error handling in Swift more intuitive and powerful with clearer messages, type safety, and user-friendly diagnostics.

@Metadata {
   @PageImage(purpose: icon, source: "ErrorKit")
}

## Overview

Swift's error handling has several limitations that make it challenging to create robust, user-friendly applications:
- The `Error` protocol's confusing behavior with `localizedDescription`
- Hard-to-understand system error messages
- Limited type safety in error propagation
- Difficulties with error chain debugging
- Challenges in collecting meaningful feedback from users

ErrorKit addresses these challenges with a suite of lightweight, interconnected features you can adopt progressively.

## Core Features

These foundational features improve how you define and present errors:

@Links(visualStyle: detailedGrid) {
   - <doc:Throwable-Protocol>
   - <doc:Enhanced-Error-Descriptions>
}

## Swift 6 Typed Throws Support

Swift 6 introduces typed throws (`throws(ErrorType)`), bringing compile-time type checking to error handling. ErrorKit makes this powerful feature practical with solutions for its biggest challenges:

@Links(visualStyle: detailedGrid) {
   - <doc:Typed-Throws-and-Error-Nesting>
   - <doc:Error-Chain-Debugging>
}

## Ready-to-Use Tools

These practical tools help you implement robust error handling with minimal effort:

@Links(visualStyle: detailedGrid) {
   - <doc:Built-in-Error-Types>
   - <doc:User-Feedback-with-Logs>
}

## How These Features Work Together

ErrorKit's features are designed to complement each other while remaining independently useful:

1. **Start with improved error definitions** using `Throwable` for custom errors and `userFriendlyMessage(for:)` for system errors.

2. **Add type safety with Swift 6 typed throws**, using the `Catching` protocol to solve nested error challenges. This pairs with error chain debugging to understand error flows through your app.

3. **Save time with ready-made tools**: built-in error types for common scenarios and simple log collection for user feedback.

Each feature builds upon the foundations laid by the previous ones, but you can adopt any part independently based on your needs.

## Adoption Path

Here's a practical adoption strategy:

1. Replace `Error` with `Throwable` in your custom error types
2. Use `ErrorKit.userFriendlyMessage(for:)` when showing system errors
3. Adopt built-in error types where they fit your needs
4. Implement typed throws with `Catching` for more robust error flows
5. Add error chain debugging to improve error visibility
6. Integrate log collection with your feedback system
