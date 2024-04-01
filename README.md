# UnsafeSendable

A quick POC for a macro that can make a property `Sendable` without the need for marking the outer type `@unchecked Sendable` or using `@preconncurrency import`.

For example, [`Logger` should be sendable](https://forums.developer.apple.com/forums/thread/747816?answerId=781922022#781922022) and the [`shared` instance of `FileManager` is thread-safe](https://forums.developer.apple.com/forums/thread/747816?answerId=781922022#781922022), but these types are not marked `Sendable`.

```swift
import os
import UnsafeSendable

final class SendableClass: Sendable {
    @UnsafeSendable
    private let logger: Logger

    init() {
        logger = Logger()
    }
}
```

## Why not a property wrapper?

It is possible to write a property wrapper that provides the `Sendable` checking:

```swift
import os

@propertyWrapper
struct UnsafeSendable<Wrapped>: @unchecked Sendable {
    var wrappedValue: Wrapped

    init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }

    init(initialValue: Wrapped) {
        wrappedValue = initialValue
    }
}

final class SendableClass: Sendable {
    @UnsafeSendable
    private var logger: Logger

    init(logger: Logger = Logger()) {
        self.logger = logger
    }
}
```

However, this provides private mutability via `_wrappedProperty`. To fix this we would need to mark `wrappedValue` as `let`, however this then will not allow for the value to be created in the initialiser:

```swift
import os

@propertyWrapper
struct UnsafeSendable<Wrapped>: @unchecked Sendable {
    let wrappedValue: Wrapped

    init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }

    init(initialValue: Wrapped) {
        wrappedValue = initialValue
    }
}

final class SendableClass: Sendable {
    @UnsafeSendable
    private var logger: Logger

    init(logger: Logger = Logger()) {
        self.logger = logger // Cannot assign to property: 'logger' is a get-only property
    }
}
```

To support this the
