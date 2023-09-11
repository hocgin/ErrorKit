import Foundation

@freestanding(expression)
public macro RichError(code: Int, message: String) -> NSError = #externalMacro(module: "ErrorKitMacros", type: "RichErrorMacro")
