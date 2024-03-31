import SubscriberKit
import Queues
import Vapor


extension Application: SubscriberDelegate {
    
    public func subscription(_ subscription: Subscription, received payload: Data) async throws {
        try await queues.queue.dispatch(ExtractReceivedContentJob.self, .init(data: payload))
    }
    
    public func subscription(_ subscription: Subscription, verified: SubscriptionVerification) async throws {
        logger.trace("Subscription verified", metadata: [
            "topic": "\(verified.topic)",
            "challenge": "\(verified.challenge)",
            "mode": "\(verified.mode)",
            "leaseSeconds": "\(verified.leaseSeconds ?? 0)",
        ])
    }
    
    public func subscription(_ subscription: Subscription, denied: SubscriptionDenial) async throws {
        logger.trace("Subscription verified", metadata: [
            "topic": "\(denied.topic)",
            "reason": "\(denied.reason ?? "")",
        ])
    }
    
}
