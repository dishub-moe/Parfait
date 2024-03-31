import SubscriberKit
import SubscriberVapor
import Vapor


struct Subscribe: SubscribeCommand {
    
    struct Signature: CommandSignature {
        
        @Option(name: "topic")
        var topic: String?

        @Option(name: "lease-seconds")
        var leaseSeconds: Int?

        @Option(name: "preferred-hub")
        var preferredHub: String?
        
    }
    
    var callbackURLGenerator: CallbackURLGenerator { storedCallbackURLGenerator }
    
    var delegate: SubscriberDelegate { storedDelegate }

    let help = "Subscribe to a topic"

    private let storedCallbackURLGenerator: CallbackURLGenerator & Sendable

    private let storedDelegate: SubscriberDelegate & Sendable

    init(
        callbackURLGenerator: CallbackURLGenerator & Sendable,
        delegate: SubscriberDelegate & Sendable
    ) {
        self.storedCallbackURLGenerator = callbackURLGenerator
        self.storedDelegate = delegate
    }

    func input(
        using context: CommandContext,
        signature: Signature
    ) async throws -> (
        topic: String,
        leaseSeconds: Int?,
        preferredHub: String?
    ) {
        let topic = signature.topic ?? context.console.ask("Please type topic URL to subscribe")
        let leaseSeconds = signature.leaseSeconds ?? Int(context.console.ask("Please type lease seconds"))
        let preferredHub = signature.preferredHub ?? context.console.ask("Please type preferred hub URL")
        return (topic, leaseSeconds, preferredHub)
    }
    
}
