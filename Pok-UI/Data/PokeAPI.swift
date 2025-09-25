//// PokeAPI.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 22-09-25.
//

import Foundation

public protocol PokeAPIProtocol {
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonList
    func fetchPokemonDetails(_ idOrName: String) async throws -> PokemonDetails
    func fetchPokemonSpecies(_ idOrName: String) async throws -> PokemonSpecies
    func fetchArtworkURL(id: Int) async throws -> URL?
}

public final class PokeAPI: PokeAPIProtocol {

    private let http: HTTPClient
    private let baseURL: URL
    private let jsonDecoder: JSONDecoder

    public init(http: HTTPClient,
                baseURL: URL = URL(string: "https://pokeapi.co/api/v2")!) {
        self.http = http
        self.baseURL = baseURL
        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        self.jsonDecoder = dec
    }

    public func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonList {
        let req = Request(
            baseURL: baseURL,
            path: "/pokemon",
            method: .get,
            query: [
                "limit": String(limit),
                "offset": String(offset)
            ],
            headers: [:],
            body: nil
        )
        return try await http.send(req, decodeWith: jsonDecoder) as PokemonList
    }

    public func fetchPokemonDetails(_ idOrName: String) async throws -> PokemonDetails {
        let req = Request(
            baseURL: baseURL,
            path: "/pokemon/\(idOrName)",
            method: .get,
            query: [:],
            headers: [:],
            body: nil
        )
        return try await http.send(req, decodeWith: jsonDecoder) as PokemonDetails
    }

    public func fetchPokemonSpecies(_ idOrName: String) async throws -> PokemonSpecies {
        let req = Request(
            baseURL: baseURL,
            path: "/pokemon-species/\(idOrName)",
            method: .get,
            query: [:],
            headers: [:],
            body: nil
        )
        return try await http.send(req, decodeWith: jsonDecoder) as PokemonSpecies
    }
    
    public func fetchArtworkURL(id: Int) async throws -> URL? {
        let d = try await fetchPokemonDetails(String(id))
        return d.sprites.other?.officialArtwork?.frontDefault ?? d.sprites.frontDefault
    }
}
