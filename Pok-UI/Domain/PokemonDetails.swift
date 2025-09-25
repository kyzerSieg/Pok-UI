//// PokemonDetails.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 23-09-25.
//

import Foundation

public struct PokemonDetails: Codable {
    public let id: Int
    public let name: String
    public let height: Int
    public let weight: Int
    public let baseExperience: Int
    public let types: [PokemonType]
    public let abilities: [PokemonAbility]
    public let sprites: PokemonSprites
}

public struct PokemonType: Codable {
    public let slot: Int
    public let type: PokemonKind
}

public struct PokemonKind: Codable {
    public let name: String
    public let url: URL
}

public struct PokemonAbility: Codable {
    public let ability: PokemonKind
    public let isHidden: Bool
    public let slot: Int
}

public struct PokemonSprites: Codable {
    public let frontDefault: URL?
    public let other: SpritesOther?
}

public struct SpritesOther: Codable {
    public let officialArtwork: OfficialArtwork?

    private enum CodingKeys: String, CodingKey {
        case officialArtwork = "official-artwork"
    }
}

public struct OfficialArtwork: Codable {
    public let frontDefault: URL?

    private enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
    }
}
