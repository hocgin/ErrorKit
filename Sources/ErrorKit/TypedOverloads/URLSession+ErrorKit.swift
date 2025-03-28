import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// An enumeration that represents various errors that can occur when performing network requests with `URLSession`.
public enum URLSessionError: Throwable {
   /// The request timed out.
   case timeout

   /// The're no network connection.
   case noNetwork

   /// The host could not be found.
   case cannotFindHost

   /// Something was wrong with the URL.
   case badURL

   /// The network request was cancelled.
   case cancelled

   /// An SSL error occurred during the request.
   case sslError

   /// A network error occurred that doesn't match a specific case.
   case networkError(Error)

   /// The server returned a 401 Unauthorized status code.
   case unauthorized(bodyData: Data?)

   /// The server returned a 402 Payment Required status code.
   case paymentRequired(bodyData: Data?)

   /// The server returned a 403 Forbidden status code.
   case forbidden(bodyData: Data?)

   /// The server returned a 404 Not Found status code.
   case notFound(bodyData: Data?)

   /// The server returned a 405 Method Not Allowed status code.
   case methodNotAllowed(bodyData: Data?)

   /// The server returned a 406 Not Acceptable status code.
   case notAcceptable(bodyData: Data?)

   /// The server returned a 408 Request Timeout status code.
   case requestTimeout(bodyData: Data?)

   /// The server returned a 409 Conflict status code.
   case conflict(bodyData: Data?)

   /// The server returned a 415 Unsupported Media Type status code.
   case unsupportedMediaType(bodyData: Data?)

   /// The server returned a 429 Too Many Requests status code.
   case tooManyRequests(bodyData: Data?)

   /// The server returned a generic 4xx Bad Request status code (fallback).
   case badRequest(bodyData: Data?)

   /// The server returned a 500 Internal Server Error status code.
   case serverError

   /// An unknown error occurred.
   case unknownStatusCode(Int)

   /// A general error case for any other unforeseen errors.
   case other(Error)

   public var userFriendlyMessage: String {
      switch self {
      case .timeout:
         return String.localized(
            key: "TypedOverloads.URLSession.timeout",
            defaultValue: "The request timed out. Please try again."
         )
      case .noNetwork:
         return String.localized(
            key: "TypedOverloads.URLSession.noNetwork",
            defaultValue: "No network connection found. Please check your internet."
         )
      case .cannotFindHost:
         return String.localized(
            key: "TypedOverloads.URLSession.cannotFindHost",
            defaultValue: "Cannot find host. Please check your internet connection and try again."
         )
      case .badURL:
         return String.localized(
            key: "TypedOverloads.URLSession.badURL",
            defaultValue: "The URL is malformed. Please check it and try again or report a bug."
         )
      case .cancelled:
         return String.localized(
            key: "TypedOverloads.URLSession.cancelled",
            defaultValue: "The request was cancelled. Please try again if this wasn't intended."
         )
      case .sslError:
         return String.localized(
            key: "TypedOverloads.URLSession.sslError",
            defaultValue: "There was an SSL error. Please check the server's certificate."
         )
      case .networkError(let error):
         return ErrorKit.userFriendlyMessage(for: error)
      case .unauthorized:
         return String.localized(
            key: "TypedOverloads.URLSession.unauthorized",
            defaultValue: "You are not authorized to access this resource (401)."
         )
      case .paymentRequired:
         return String.localized(
            key: "TypedOverloads.URLSession.paymentRequired",
            defaultValue: "Payment is required to access this resource (402)."
         )
      case .forbidden:
         return String.localized(
            key: "TypedOverloads.URLSession.forbidden",
            defaultValue: "You do not have permission to access this resource (403)."
         )
      case .notFound:
         return String.localized(
            key: "TypedOverloads.URLSession.notFound",
            defaultValue: "The requested resource could not be found (404)."
         )
      case .methodNotAllowed:
         return String.localized(
            key: "TypedOverloads.URLSession.methodNotAllowed",
            defaultValue: "The HTTP method is not allowed for this resource (405)."
         )
      case .notAcceptable:
         return String.localized(
            key: "TypedOverloads.URLSession.notAcceptable",
            defaultValue: "The requested resource cannot produce an acceptable response (406)."
         )
      case .requestTimeout:
         return String.localized(
            key: "TypedOverloads.URLSession.requestTimeout",
            defaultValue: "The request timed out (408). Please try again."
         )
      case .conflict:
         return String.localized(
            key: "TypedOverloads.URLSession.conflict",
            defaultValue: "There was a conflict with the request (409). Please review and try again."
         )
      case .unsupportedMediaType:
         return String.localized(
            key: "TypedOverloads.URLSession.unsupportedMediaType",
            defaultValue: "The request entity has an unsupported media type (415)."
         )
      case .tooManyRequests:
         return String.localized(
            key: "TypedOverloads.URLSession.tooManyRequests",
            defaultValue: "Too many requests have been sent. Please wait and try again (429)."
         )
      case .badRequest:
         return String.localized(
            key: "TypedOverloads.URLSession.badRequest",
            defaultValue: "The request was malformed (400). Please review and try again."
         )
      case .serverError:
         return String.localized(
            key: "TypedOverloads.URLSession.serverError",
            defaultValue: "The server encountered an error (500). Please try again later."
         )
      case .unknownStatusCode(let statusCode):
         return String.localized(
            key: "TypedOverloads.URLSession.unknown",
            defaultValue: "An unknown status code was received from the server: \(statusCode)"
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
      } catch {
         throw mapToThrowable(error: error as NSError)
      }
   }

   /// A typed-throws overload of `data(from:)` that maps known errors to a custom `URLSessionError` enum for enhanced error handling.
   public func throwableData(from url: URL) async throws -> (Data, URLResponse) {
      do {
         return try await self.data(from: url)
      } catch {
         throw mapToThrowable(error: error as NSError)
      }
   }

   private func mapToThrowable(error: NSError) -> URLSessionError {
      switch (error.domain, error.code) {
      case (NSURLErrorDomain, NSURLErrorTimedOut): .timeout
      case (NSURLErrorDomain, NSURLErrorNetworkConnectionLost): .noNetwork
      case (NSURLErrorDomain, NSURLErrorNotConnectedToInternet): .noNetwork
      case (NSURLErrorDomain, NSURLErrorCannotFindHost): .cannotFindHost
      case (NSURLErrorDomain, NSURLErrorCannotConnectToHost): .serverError
      case (NSURLErrorDomain, NSURLErrorCancelled): .cancelled
      case (NSURLErrorDomain, NSURLErrorBadURL): .badURL
      case (NSURLErrorDomain, NSURLErrorSecureConnectionFailed): .sslError
      default: .networkError(error)
      }
   }

   /// A method to handle HTTP status codes and provide better error handling for different cases.
   public func handleHTTPStatusCode(_ statusCode: Int, data: Data?) throws -> Data? {
      switch statusCode {
      case 200...299: // Success range
         return data
      case 400...499: // Client errors
         switch statusCode {
         case 401:
            throw URLSessionError.unauthorized(bodyData: data)
         case 402:
            throw URLSessionError.paymentRequired(bodyData: data)
         case 403:
            throw URLSessionError.forbidden(bodyData: data)
         case 404:
            throw URLSessionError.notFound(bodyData: data)
         case 405:
            throw URLSessionError.methodNotAllowed(bodyData: data)
         case 406:
            throw URLSessionError.notAcceptable(bodyData: data)
         case 408:
            throw URLSessionError.requestTimeout(bodyData: data)
         case 409:
            throw URLSessionError.conflict(bodyData: data)
         case 415:
            throw URLSessionError.unsupportedMediaType(bodyData: data)
         case 429:
            throw URLSessionError.tooManyRequests(bodyData: data)
         default:
            throw URLSessionError.badRequest(bodyData: data)
         }
      case 500...599: // Server errors
         throw URLSessionError.serverError
      default:
         throw URLSessionError.unknownStatusCode(statusCode)
      }
   }
}
