import SubscriberKit
import SubscriberVapor
import Vapor


struct CallbackRoutes: SubscriberVapor.CallbackRoutes, Sendable {

    var callbackURLGenerator: CallbackURLGenerator { storedCallbackURLGenerator }

    var delegate: SubscriberDelegate { storedDelegate }

    private let storedCallbackURLGenerator: CallbackURLGenerator & Sendable

    private let storedDelegate: SubscriberDelegate & Sendable

    init(
        callbackURLGenerator: CallbackURLGenerator & Sendable,
        delegate: SubscriberDelegate & Sendable
    ) {
        self.storedCallbackURLGenerator = callbackURLGenerator
        self.storedDelegate = delegate
    }

    func boot(routes: RoutesBuilder) throws {
        routes.group("\(callbackURLGenerator.callbackPath)") { routes in
            routes.group(":id") { routes in
                routes.get("", use: get)
                routes.post("", use: post)
            }
        }
    }
    
    func get(request: Request) async throws -> Response {
        if let validation = try? request.query.decode(SubscriptionValidation.self) {
            return try await verify(request, validation: validation)
        }
        return .init(status: .notAcceptable)
    }
    
    func post(request: Request) async throws -> Response {
        return try await deliver(request: request)
    }
    
}
