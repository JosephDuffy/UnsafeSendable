# UnsafeSendable

A macro that can make a property `Sendable` without the need for marking the outer type `@unchecked Sendable` or using `@preconncurrency import`.

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

## Why would you want this?

Adding `@unchecked Sendable` to a type can lead to bugs being introduced in the future if a non-sendable property is later added. It is not possible to mark a single property `@unchecked Sendable` (or anything to that effect).

Rather than effectively turning off the sendability checking for _all_ properties of the type this allows the checking to be turned off for a _single_ property.

This is particularly useful when using a types that _should_ be marked `Sendable` but isn't (such as [`Logger`](https://forums.developer.apple.com/forums/thread/747816?answerId=781922022#781922022)), or when some instances of a type _is_ thread-safe but cannot be marked `Sendable`, such as the [`shared` instance of `FileManager`](https://developer.apple.com/documentation/foundation/filemanager#1651181).

## Why not a property wrapper?

It is possible to write a property wrapper that produces similar results:

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

However, this provides private mutability because `logger` is a `var`. To fix this we would need to mark `wrappedValue` as `let`, however this then requires 2 separate property wrappers (one mutable, one not) and does not allow for the value to be created in the initialiser: 

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

To support all of these scenarios the macro:

- Uses a getter and a setter (which honours `let`, `var`, `private(set)`, etc.)
- Uses an `init` for the property (which allows for default values, initialisation in the type's `init`, or both)
- Stores the actual value in a private property
