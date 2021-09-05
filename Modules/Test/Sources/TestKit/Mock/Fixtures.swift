// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum Fixtures {

    public static func load<T: Decodable>(name: String, in bundle: Bundle) -> T? {
        guard let data = loadJSONData(filename: name, in: bundle) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }

    public static func loadJSONData(filename: String, in bundle: Bundle) -> Data? {
        guard let file = bundle.url(forResource: filename, withExtension: "json") else {
            return nil
        }
        return try? Data(contentsOf: file)
    }

    public static func loadJSONString(name: String, in bundle: Bundle) -> String? {
        guard let data = loadJSONData(filename: name, in: bundle) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    public static func loadJSONDictionary(name: String, in bundle: Bundle) -> [String: Any]? {
        loadJSON(name: name, in: bundle) as? [String: Any]
    }

    public static func loadJSONArray(name: String, in bundle: Bundle) -> [Any]? {
        loadJSON(name: name, in: bundle) as? [Any]
    }

    private static func loadJSON(name: String, in bundle: Bundle) -> Any? {
        guard let data = loadJSONData(filename: name, in: bundle) else {
            return nil
        }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
}
