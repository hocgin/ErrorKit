import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(ErrorKitMacros)
import ErrorKitMacros

let testMacros: [String: Macro.Type] = [
   "RichError": RichErrorMacro.self,
]
#endif

final class ErrorKitTests: XCTestCase {
   func testMacro() throws {
      #if canImport(ErrorKitMacros)
      assertMacroExpansion(
            """
            #RichError(code: 1156, message: "parsing failed with error code \\(someVariable)")
            """,
            expandedSource: """
            NSError.generic(code: 1156, message: "parsing failed with error code \\(someVariable)")
            """,
            macros: testMacros
      )
      #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
      #endif
   }
}
