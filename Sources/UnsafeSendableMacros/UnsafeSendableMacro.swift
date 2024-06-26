import SwiftCompilerPlugin
#if canImport(SwiftSyntax510)
import SwiftDiagnostics
#else
@preconcurrency import SwiftDiagnostics
#endif
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct UnsafeSendableMacro: AccessorMacro, PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            throw ErrorDiagnosticMessage(id: "declaration-not-variable", message: "@UnsafeSendable must be attached to a property")
        }
        let storageName = try storageNameForProperty(variable)
        var accessors: [AccessorDeclSyntax] = [
            """
            @storageRestrictions(initializes: \(raw: storageName))
            init(initialValue)  {
                \(raw: storageName) = UnsafeSendable(unsafeWrapped: initialValue)
            }
            """,
            """
            get {
                \(raw: storageName).wrapped
            }
            """
        ]

        if variable.bindingSpecifier.tokenKind == .keyword(.var) {
            accessors.append(
                """
                set {
                    \(raw: storageName).wrapped = newValue
                }
                """
            )
        }

        return accessors
    }

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard
            let variable = declaration.as(VariableDeclSyntax.self),
            let binding = variable.bindings.first,
            let typeAnnotation = binding.typeAnnotation
        else {
            throw ErrorDiagnosticMessage(id: "can-not-find-type", message: "@UnsafeSendable requires an explicit type")
        }

        let storageName = try storageNameForProperty(variable)
        return [
            "private \(variable.bindingSpecifier.trimmed) \(raw: storageName): UnsafeSendable<\(typeAnnotation.type.trimmed)>"
        ]
    }

    private static func storageNameForProperty(
        _ variable: VariableDeclSyntax
    ) throws -> String {
        guard
            let binding = variable.bindings.first,
            let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.trimmed.identifier
        else {
            throw ErrorDiagnosticMessage(id: "declaration-not-variable", message: "@UnsafeSendable must be attached to a property")
        }

        return "_unsafeSendable_\(identifier)"
    }
}

private struct ErrorDiagnosticMessage: DiagnosticMessage, Error {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    init(id: String, message: String) {
        self.message = message
        diagnosticID = MessageID(domain: "uk.josephduffy.UnsafeSendable", id: id)
        severity = .error
    }
}

@main
struct UnsafeSendablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UnsafeSendableMacro.self,
    ]
}
