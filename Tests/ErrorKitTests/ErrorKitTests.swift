import Foundation
import Testing
@testable import ErrorKit

enum ErrorKitTests {
   struct SomeLocalizedError: LocalizedError {
      let errorDescription: String? = "Something failed."
      let failureReason: String? = "It failed because it wanted to."
      let recoverySuggestion: String? = "Try again later."
      let helpAnchor: String? = "https://github.com/apple/swift-error-kit#readme"
   }

   struct SomeThrowable: Throwable {
      let userFriendlyMessage: String = "Something failed hard."
   }

   enum UserFriendlyMessage {
      @Test
      static func localizedError() {
         #expect(ErrorKit.userFriendlyMessage(for: SomeLocalizedError()) == "Something failed. It failed because it wanted to. Try again later.")
      }

      @Test
      static func nsError() {
         let nsError = NSError(domain: "SOME", code: 1245, userInfo: [NSLocalizedDescriptionKey: "Something failed."])
         #expect(ErrorKit.userFriendlyMessage(for: nsError) == "[SOME: 1245] Something failed.")
      }

      @Test
      static func throwable() async throws {
         #expect(ErrorKit.userFriendlyMessage(for: SomeThrowable()) == "Something failed hard.")
      }

      @Test
      static func nested() async throws {
         let nestedError = DatabaseError.caught(FileError.caught(PermissionError.denied(permission: "~/Downloads/Profile.png")))
         #expect(ErrorKit.userFriendlyMessage(for: nestedError) == "Access to ~/Downloads/Profile.png was declined. To use this feature, please enable the permission in your device Settings.")
      }
   }

   enum ErrorChainDescription {
      @Test
      static func localizedError() {
         #expect(
            ErrorKit.errorChainDescription(for: SomeLocalizedError())
            ==
            """
            SomeLocalizedError [Struct]
            └─ userFriendlyMessage: "Something failed. It failed because it wanted to. Try again later."
            """
         )
      }

      @Test
      static func nsError() {
         let nsError = NSError(domain: "SOME", code: 1245, userInfo: [NSLocalizedDescriptionKey: "Something failed."])
         #expect(
            ErrorKit.errorChainDescription(for: nsError)
            ==
            """
            NSError [Class]
            └─ userFriendlyMessage: "[SOME: 1245] Something failed."
            """
         )
      }

      @Test
      static func throwableStruct() {
         #expect(
            ErrorKit.errorChainDescription(for: SomeThrowable())
            == 
            """
            SomeThrowable [Struct]
            └─ userFriendlyMessage: "Something failed hard."
            """
         )
      }

      @Test
      static func throwableEnum() {
         #expect(
            ErrorKit.errorChainDescription(for: PermissionError.restricted(permission: "~/Downloads/Profile.png"))
            ==
            """
            PermissionError.restricted(permission: "~/Downloads/Profile.png")
            └─ userFriendlyMessage: "Access to ~/Downloads/Profile.png is currently restricted. This may be due to system settings or parental controls."
            """
         )
      }

      @Test
      static func shallowNested() {
         let nestedError = DatabaseError.caught(FileError.fileNotFound(fileName: "App.sqlite"))
         #expect(
            ErrorKit.errorChainDescription(for: nestedError)
            ==
            """
            DatabaseError
            └─ FileError.fileNotFound(fileName: "App.sqlite")
               └─ userFriendlyMessage: "The file App.sqlite could not be located. Please verify the file path and try again."
            """
         )
      }

      @Test
      static func deeplyNestedThrowablesWithEnumLeaf() {
         let nestedError = StateError.caught(
            OperationError.caught(
               DatabaseError.caught(
                  FileError.caught(
                     PermissionError.denied(permission: "~/Downloads/Profile.png")
                  )
               )
            )
         )
         #expect(
            ErrorKit.errorChainDescription(for: nestedError)
            ==
            """
            StateError
            └─ OperationError
               └─ DatabaseError
                  └─ FileError
                     └─ PermissionError.denied(permission: "~/Downloads/Profile.png")
                        └─ userFriendlyMessage: "Access to ~/Downloads/Profile.png was declined. To use this feature, please enable the permission in your device Settings."
            """
         )
      }

      @Test
      static func shallowNestedThrowablesWithStructLeaf() {
         let nestedError = StateError.caught(
            OperationError.caught(
               DatabaseError.caught(
                  FileError.caught(
                     SomeThrowable()
                  )
               )
            )
         )
         #expect(
            ErrorKit.errorChainDescription(for: nestedError)
            ==
            """
            StateError
            └─ OperationError
               └─ DatabaseError
                  └─ FileError
                     └─ SomeThrowable [Struct]
                        └─ userFriendlyMessage: "Something failed hard."
            """
         )
      }

      @Test
      static func shallowNestedThrowablesWithLocalizedErrorLeaf() {
         let nestedError = StateError.caught(
            OperationError.caught(
               DatabaseError.caught(
                  FileError.caught(
                     SomeLocalizedError()
                  )
               )
            )
         )
         #expect(
            ErrorKit.errorChainDescription(for: nestedError)
            ==
            """
            StateError
            └─ OperationError
               └─ DatabaseError
                  └─ FileError
                     └─ SomeLocalizedError [Struct]
                        └─ userFriendlyMessage: "Something failed. It failed because it wanted to. Try again later."
            """
         )
      }

      @Test
      static func shallowNestedThrowablesWithNSErrorLeaf() {
         let nsError = NSError(domain: "SOME", code: 1245, userInfo: [NSLocalizedDescriptionKey: "Something failed."])
         let nestedError = StateError.caught(
            OperationError.caught(
               DatabaseError.caught(
                  FileError.caught(nsError)
               )
            )
         )
         #expect(
            ErrorKit.errorChainDescription(for: nestedError)
            ==
            """
            StateError
            └─ OperationError
               └─ DatabaseError
                  └─ FileError
                     └─ NSError [Class]
                        └─ userFriendlyMessage: "[SOME: 1245] Something failed."
            """
         )
      }
   }

   // TODO: add more tests for more specific errors such as CoreData, MapKit – and also nested errors!
}
