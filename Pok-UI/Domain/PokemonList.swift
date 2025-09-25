//// PokemonList.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 23-09-25.
//

import Foundation

public struct PokemonEntry: Codable {
    public let name: String
    public let detailsURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case name
        case detailsURL = "url"
    }
}

public struct PokemonList: Codable {
    public let total: Int
    public let nextPage: URL?
    public let previousPage: URL?
    public let entries: [PokemonEntry]
    
    private enum CodingKeys: String, CodingKey {
        case total = "count"
        case nextPage = "next"
        case previousPage = "previous"
        case entries = "results"
    }
}
