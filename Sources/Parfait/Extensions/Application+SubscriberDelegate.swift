import SubscriberKit
import Vapor


extension Application: SubscriberDelegate {
    
    public func subscription(_ subscription: Subscription, received payload: Data) async throws { }
    
    public func subscription(_ subscription: Subscription, verified: SubscriptionVerification) async throws { }
    
    public func subscription(_ subscription: Subscription, denied: SubscriptionDenial) async throws { }
    
}
