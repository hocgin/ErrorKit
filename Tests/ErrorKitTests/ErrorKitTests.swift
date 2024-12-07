import Foundation
import Testing
@testable import ErrorKit

struct SomeLocalizedError: LocalizedError {
   let errorDescription: String? = "Something failed."
   let failureReason: String? = "It failed because it wanted to."
   let recoverySuggestion: String? = "Try again later."
   let helpAnchor: String? = "https://github.com/apple/swift-error-kit#readme"
}

@Test
func enhancedDescriptionLocalizedError() {
   #expect(ErrorKit.enhancedDescription(for: SomeLocalizedError()) == "Something failed. It failed because it wanted to. Try again later.")
}

@Test
func enhancedDescriptionNSError() {
   let nsError = NSError(domain: "SOME", code: 1245, userInfo: [NSLocalizedDescriptionKey: "Something failed."])
   #expect(ErrorKit.enhancedDescription(for: nsError) == "[SOME: 1245] Something failed.")
}

struct SomeThrowable: Throwable {
   let localizedDescription: String = "Something failed hard."
}

@Test
func enhancedDescriptionThrowable() async throws {
   #expect(ErrorKit.enhancedDescription(for: SomeThrowable()) == "Something failed hard.")
}

// TODO: add more tests for more specific errors such as CoreData, MapKit, etc.
