//// PokemonSpecies.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 23-09-25.
//

import Foundation

public struct PokemonSpecies: Codable {
    public let id: Int
    public let name: String
    public let order: Int
    public let genderRate: Int
    public let captureRate: Int
    public let baseHappiness: Int
    public let isBaby: Bool
    public let isLegendary: Bool
    public let isMythical: Bool
    public let hatchCounter: Int
    public let hasGenderDifferences: Bool
    public let formsSwitchable: Bool
    public let generation: NamedResource
    public let color: NamedResource
    public let shape: NamedResource
    public let habitat: NamedResource?
    public let growthRate: NamedResource
    public let eggGroups: [NamedResource]
    public let evolutionChain: APIResource
    public let flavorTextEntries: [FlavorTextEntry]
    public let names: [NameEntry]
}

public struct NamedResource: Codable {
    public let name: String
    public let url: URL
}

public struct APIResource: Codable {
    public let url: URL
}

public struct FlavorTextEntry: Codable {
    public let flavorText: String
    public let language: NamedResource
    public let version: NamedResource
}

public struct NameEntry: Codable {
    public let name: String
    public let language: NamedResource
}
