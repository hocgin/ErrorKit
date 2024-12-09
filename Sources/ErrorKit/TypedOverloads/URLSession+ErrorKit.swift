import Foundation

/// An enumeration that represents various errors that can occur when performing network requests with `URLSession`.
public enum URLSessionError: Throwable {
   /// The request timed out.
   case timeout

   /// The network connection was lost.
   case connectionLost

   /// The server returned a 404 Not Found status code.
   case notFound

   /// The server returned a 500 Internal Server Error status code.
   case serverError

   /// A network error occurred that doesn't match a specific case.
   case networkError(Error)

   /// An unknown error occurred.
   case unknownStatusCode(Int)

   /// A general error case for any other unforeseen errors.
   case other(Error)

   public var userFriendlyMessage: String {
      switch self {
      case .timeout:
         return String(
            localized: "TypedOverloads.URLSession.timeout",
            defaultValue: "The request timed out. Please try again.",
            bundle: .module
         )
      case .connectionLost:
         return String(
            localized: "TypedOverloads.URLSession.connectionLost",
            defaultValue: "The network connection was lost. Please check your connection.",
            bundle: .module
         )
      case .notFound:
         return String(
            localized: "TypedOverloads.URLSession.notFound",
            defaultValue: "The requested resource could not be found (404).",
            bundle: .module
         )
      case .serverError:
         return String(
            localized: "TypedOverloads.URLSession.serverError",
            defaultValue: "The server encountered an error (500). Please try again later.",
            bundle: .module
         )
      case .networkError(let error):
         return ErrorKit.userFriendlyMessage(for: error)
      case .unknownStatusCode(let statusCode):
         return String(
            localized: "TypedOverloads.URLSession.unknown",
            defaultValue: "An unknown status code was received from the server: \(statusCode)",
            bundle: .module
         )
      case .other(let error):
         return ErrorKit.userFriendlyMessage(for: error)
      }
   }
}

extension URLSession {
   /// A typed-throws overload of `data(for:)` that maps known errors to a custom `URLSessionError` enum for enhanced error handling.
   public func throwableData(for request: URLRequest) async throws -> (Data, URLResponse) {
      do {
         return try await self.data(for: request)
      } catch let error as NSError {
         throw mapToThrowable(error: error)
      }
   }

   /// A typed-throws overload of `data(from:)` that maps known errors to a custom `URLSessionError` enum for enhanced error handling.
   public func throwableData(from url: URL) async throws -> (Data, URLResponse) {
      do {
         return try await self.data(from: url)
      } catch let error as NSError {
         throw mapToThrowable(error: error)
      }
   }

   private func mapToThrowable(error: NSError) -> URLSessionError {
      switch (error.domain, error.code) {
      case (NSURLErrorDomain, NSURLErrorTimedOut):
         return .timeout
      case (NSURLErrorDomain, NSURLErrorNetworkConnectionLost):
         return .connectionLost
      case (NSURLErrorDomain, NSURLErrorCannotFindHost):
         return .notFound
      case (NSURLErrorDomain, NSURLErrorCannotConnectToHost):
         return .serverError
      default:
         return .networkError(error)
      }
   }

   // TODO: continue here by fixing that status code is not being used at all & improve error cases overall

   /// A method to handle HTTP status codes.
   public func handleHTTPStatusCode(_ statusCode: Int, data: Data?) throws -> Data? {
      switch statusCode {
      case 200...299: // Success range
         return data
      case 400...499: // Client errors (handle only 404 as a generic error)
         if statusCode == 404 {
            throw URLSessionError.notFound
         } else {
            return data // treat it as valid data response
         }
      case 500...599: // Server errors
         throw URLSessionError.serverError
      default:
         throw URLSessionError.unknownStatusCode(statusCode)
      }
   }
}
