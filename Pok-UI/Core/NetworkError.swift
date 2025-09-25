//// NetworkError.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 22-09-25.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case invalidResponse
    case transport(Error)
    case timeout
    case offline
    case decoding(Error)
    case clientStatus(code: Int, data: Data?)
    case serverStatus(code: Int, data: Data?)
    case unexpectedStatus(code: Int, data: Data?)

    public var httpStatus: Int? {
        switch self {
        case .clientStatus(let code, _),
             .serverStatus(let code, _),
             .unexpectedStatus(let code, _):
            return code
        default:
            return nil
        }
    }

    public var responseBodyString: String? {
        switch self {
        case .clientStatus(_, let data),
             .serverStatus(_, let data),
             .unexpectedStatus(_, let data):
            guard let d = data, !d.isEmpty else { return nil }
            return String(data: d, encoding: .utf8)
        default:
            return nil
        }
    }

    public var isRetriable: Bool {
        switch self {
        case .timeout, .offline:
            return true
        case .serverStatus(let code, _):
            return [502, 503, 504].contains(code)
        case .transport:
            return true
        default:
            return false
        }
    }
}

public extension NetworkError {
    static func from(_ error: Error) -> NetworkError {
        if let urlErr = error as? URLError {
            switch urlErr.code {
            case .timedOut:          return .timeout
            case .notConnectedToInternet, .networkConnectionLost:
                                      return .offline
            default:                 return .transport(urlErr)
            }
        }
        return .transport(error)
    }
}

public func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
    switch (lhs, rhs) {
    case (.invalidResponse, .invalidResponse),
         (.timeout, .timeout),
         (.offline, .offline):
        return true
    case (.decoding, .decoding):
        return true
    case (.transport, .transport):
        return true
    case (.clientStatus(let lc, _), .clientStatus(let rc, _)):
        return lc == rc
    case (.serverStatus(let lc, _), .serverStatus(let rc, _)):
        return lc == rc
    case (.unexpectedStatus(let lc, _), .unexpectedStatus(let rc, _)):
        return lc == rc
    default:
        return false
    }
}
