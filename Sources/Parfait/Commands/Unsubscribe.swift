import SubscriberKit
import SubscriberVapor
import Vapor


struct Unsubscribe: UnsubscribeCommand {
    
    struct Signature: CommandSignature {
        
        @Option(name: "callback") var callback: String?
        
    }
    
    var delegate: SubscriberDelegate { storedDelegate }
    
    let help = "Unsubscribe callback URL"
    
    private let storedDelegate: SubscriberDelegate & Sendable
    
    init(delegate: SubscriberDelegate & Sendable) {
        self.storedDelegate = delegate
    }
    
    func input(using context: CommandContext, signature: Signature) async throws -> (String) {
        let callback = signature.callback ?? context.console.ask("Please type callback URL to unsubscribe")
        return (callback)
    }
    
}
