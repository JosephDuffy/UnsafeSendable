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
