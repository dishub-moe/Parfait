import SubscriberKit
import SubscriberVapor
import Vapor


struct Resubscribe: ResubscribeCommand {
    
    struct Signature: CommandSignature {
        
        @Flag(name: "all")
        var resubscribeAll: Bool
        
        @Option(name: "youtube-channel-id")
        var youTubeChannelID: String?
        
        @Option(name: "lease-seconds")
        var leaseSeconds: Int?
        
    }
    
    var callbackURLGenerator: CallbackURLGenerator { storedCallbackURLGenerator }
    
    var delegate: SubscriberDelegate { storedDelegate }
    
    var bothCallbackAndTopicPresentErrorMessage: String = "Both callback and topic options are present. Please use only one option to prevent ambiguity."
    
    let help = "Resubscribe to existing subscription(s)"
    
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
        resubscribeAll: Bool,
        topic: String?,
        callback: String?,
        leaseSeconds: Int?
    ) {
        if let youTubeChannelID = signature.youTubeChannelID {
            return (
                signature.resubscribeAll,
                "https://www.youtube.com/xml/feeds/videos.xml?channel_id=\(youTubeChannelID)",
                nil,
                signature.leaseSeconds
            )
        }
        return (
            signature.resubscribeAll,
            nil,
            nil,
            signature.leaseSeconds
        )
    }
    
    func confirmUserBeforeResubscribeAllSubscriptions(
        using context: CommandContext
    ) async throws -> Bool {
        return context.console.confirm("Are you sure want to resubscribe to all subscriptions?")
    }
    
}
