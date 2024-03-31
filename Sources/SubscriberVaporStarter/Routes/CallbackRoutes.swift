import SubscriberKit
import SubscriberVapor
import Vapor


struct CallbackRoutes: SubscriberVapor.CallbackRoutes {
    
    let callbackURLGenerator: CallbackURLGenerator
    
    let delegate: SubscriberDelegate
    
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
