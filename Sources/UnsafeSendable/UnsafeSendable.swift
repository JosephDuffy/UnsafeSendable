@attached(accessor, names: named(init), named(get))
@attached(peer, names: prefixed(_unsafeSendable_))
public macro UnsafeSendable() = #externalMacro(module: "UnsafeSendableMacros", type: "UnsafeSendableMacro")

public struct UnsafeSendable<Wrapped>: @unchecked Sendable {
    public var wrapped: Wrapped

    public init(unsafeWrapped wrapped: Wrapped) {
        self.wrapped = wrapped
    }

    @available(*, deprecated, message: "Wrapper is not needed when `Wrapped` is Sendable")
    public init(unsafeWrapped wrapped: Wrapped) where Wrapped: Sendable {
        self.wrapped = wrapped
    }
}
