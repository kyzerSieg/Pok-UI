//// HTTPClient.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 22-09-25.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public protocol HTTPClient {
    func send(_ request: Request) async throws -> (Data, HTTPURLResponse)
    func send<T: Decodable>(_ request: Request, decodeWith decoder: JSONDecoder) async throws -> T
}

public final class URLSessionHTTPClient: HTTPClient {

    private let session: URLSession

    public init(configuration: URLSessionConfiguration = .default) {
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }

    public init(session: URLSession) {
        self.session = session
    }

    public func send(_ request: Request) async throws -> (Data, HTTPURLResponse) {
        let urlRequest = try request.asURLRequest()
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            try ResponseValidator.validate(http, data: data)
            return (data, http)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.transport(error)
        }
    }

    public func send<T: Decodable>(_ request: Request, decodeWith decoder: JSONDecoder) async throws -> T {
        let (data, _) = try await send(request)
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}

enum ResponseValidator {
    static func validate(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200...299:
            return
        case 400...499:
            throw NetworkError.clientStatus(code: response.statusCode, data: data)
        case 500...599:
            throw NetworkError.serverStatus(code: response.statusCode, data: data)
        default:
            throw NetworkError.unexpectedStatus(code: response.statusCode, data: data)
        }
    }
}
