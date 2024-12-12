import Testing
@testable import ErrorKit

enum ExplicitDescriptionError: Throwable {
   case somethingFailed
   case reuestTimeout

   var userFriendlyMessage: String {
      switch self {
      case .somethingFailed: "Something failed unexpectedly"
      case .reuestTimeout: "Request timed out"
      }
   }
}

@Test
func explicitDescriptionOutput() async throws {
   do {
      throw ExplicitDescriptionError.somethingFailed
   } catch {
      #expect(error.localizedDescription == "Something failed unexpectedly")
   }
}

enum RawValueDescriptionError: String, Throwable {
   case somethingFailed = "Something failed unexpectedly"
   case reqestTimeout = "Request timed out"
}

@Test
func rawValueDescriptionOutput() async throws {
   do {
      throw RawValueDescriptionError.reqestTimeout
   } catch {
      #expect(error.localizedDescription == "Request timed out")
   }
}
