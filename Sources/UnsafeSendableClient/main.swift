import UnsafeSendable

struct NotSendableType {
    var property: Int = 0

    init() {}

    init(property: Int) {
        self.property = property
    }
}

@available(*, unavailable)
extension NotSendableType: @unchecked Sendable {}

struct MySendableType: Sendable {
    @UnsafeSendable
    var actuallySendableProperty: NotSendableType = NotSendableType()

    init() {}

    init(actuallySendableProperty: NotSendableType) {
        self.actuallySendableProperty = actuallySendableProperty
    }
}

final class SendableClass: Sendable {
    @UnsafeSendable
    let actuallySendableProperty: NotSendableType = NotSendableType()
}

var mySendableType = MySendableType()
print(mySendableType.actuallySendableProperty.property) // prints 0
mySendableType.actuallySendableProperty.property = 1
print(mySendableType.actuallySendableProperty.property) // prints 1

var mySendableType2 = MySendableType(actuallySendableProperty: NotSendableType(property: 2))
print(mySendableType2.actuallySendableProperty.property) // prints 2
