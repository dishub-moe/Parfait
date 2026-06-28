import SubscriberVapor
import Vapor


extension Application: @retroactive CallbackURLGenerator {
    
    public var baseURL: String { Environment.get("BASE_URL")! }
    
    public var callbackPath: String { Environment.get("CALLBACK_PATH")! }
    
}
