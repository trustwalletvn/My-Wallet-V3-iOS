// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct DeepLinkPayload {
    public let route: DeepLinkRoute
    public let params: [String: String]
}

extension DeepLinkPayload {
    public static func create(from url: String, supportedRoutes: [DeepLinkRoute]) -> DeepLinkPayload? {
        guard let route = DeepLinkRoute.route(from: url, supportedRoutes: supportedRoutes) else { return nil }
        return DeepLinkPayload(route: route, params: extractParams(from: url))
    }

    private static func extractParams(from url: String) -> [String: String] {
        guard let lastPathWithProperties = url.components(separatedBy: "/").last else {
            return [:]
        }

        let pathToParametersComponents = lastPathWithProperties.components(separatedBy: "?")

        var parameters = [String: String]()
        let parameterPairs = pathToParametersComponents.last?.components(separatedBy: "&")
        parameterPairs?.forEach { pair in
            let paramComponents = pair.components(separatedBy: "=")
            guard let key = paramComponents.first,
                  let value = paramComponents.last?.removingPercentEncoding
            else {
                return
            }
            parameters[key] = value
        }
        return parameters
    }
}
