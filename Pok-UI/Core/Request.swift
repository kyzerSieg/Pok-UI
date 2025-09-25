//// Request.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 22-09-25.
//

import Foundation

public enum HTTPMethod: String {
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
}

public enum RequestError: Error {
    case invalidBaseURL
    case invalidURLComponents
    case invalidBodyEncoding
}

public struct Request {
    public let baseURL: URL
    public let path: String
    public let method: HTTPMethod
    public var query: [String: String]?
    public var headers: [String: String]?
    public var body: Data?

    public init(
        baseURL: URL,
        path: String,
        method: HTTPMethod,
        query: [String: String]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.query = query
        self.headers = headers
        self.body = body
    }

    public func asURLRequest(cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
                             timeout: TimeInterval = 30) throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path.trimmingCharacters(in: CharacterSet(charactersIn: "/")), isDirectory: false)

        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let query, !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let finalURL = components?.url else {
            throw RequestError.invalidURLComponents
        }

        var request = URLRequest(url: finalURL, cachePolicy: cachePolicy, timeoutInterval: timeout)
        request.httpMethod = method.rawValue

        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if let body {
            request.httpBody = body
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
        }

        return request
    }
}

public extension Request {
    static func json<T: Encodable>(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .post,
        query: [String: String]? = nil,
        headers: [String: String]? = nil,
        json: T,
        encoder: JSONEncoder = .init()
    ) throws -> Request {
        let data = try encoder.encode(json)
        var allHeaders = headers ?? [:]
        if allHeaders["Content-Type"] == nil {
            allHeaders["Content-Type"] = "application/json; charset=utf-8"
        }
        return Request(baseURL: baseURL, path: path, method: method, query: query, headers: allHeaders, body: data)
    }

    static func json(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .post,
        query: [String: String]? = nil,
        headers: [String: String]? = nil,
        jsonObject: [String: Any],
        options: JSONSerialization.WritingOptions = []
    ) throws -> Request {
        guard JSONSerialization.isValidJSONObject(jsonObject) else {
            throw RequestError.invalidBodyEncoding
        }
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: options)
        var allHeaders = headers ?? [:]
        if allHeaders["Content-Type"] == nil {
            allHeaders["Content-Type"] = "application/json; charset=utf-8"
        }
        return Request(baseURL: baseURL, path: path, method: method, query: query, headers: allHeaders, body: data)
    }

    static func get(
        baseURL: URL,
        path: String,
        query: [String: String]? = nil,
        headers: [String: String]? = nil
    ) -> Request {
        Request(baseURL: baseURL, path: path, method: .get, query: query, headers: headers, body: nil)
    }
}
