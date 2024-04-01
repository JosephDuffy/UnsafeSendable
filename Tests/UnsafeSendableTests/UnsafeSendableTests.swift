import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(UnsafeSendableMacros)
import UnsafeSendableMacros

let testMacros: [String: Macro.Type] = [
    "UnsafeSendable": UnsafeSendableMacro.self,
]
#endif

final class UnsafeSendableTests: XCTestCase {

}
