//// PokeViewModel.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 22-09-25.
//

import Foundation

@MainActor
final class PokeViewModel: ObservableObject {
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String? = nil

    @Published private(set) var list: [PokemonEntry] = []
    @Published private(set) var total: Int = 0
    @Published private(set) var selectedDetails: PokemonDetails?
    @Published private(set) var selectedSpecies: PokemonSpecies?
    @Published private(set) var artworkByID: [Int: URL] = [:]
    
    private let images: ImageCacheServiceProtocol
    private let api: PokeAPIProtocol = PokeAPI(http: URLSessionHTTPClient())
    private let limit: Int = 50
    private var offset: Int = 0

    init(images: ImageCacheServiceProtocol = ImageCacheService()) {
        self.images = images
    }
    
    func reset() {
        selectedDetails = nil
        selectedSpecies = nil
        errorMessage = nil
    }
    
    func loadInitial() async {
        offset = 0
        await loadPage(reset: true)
    }

    func loadMore() async {
        guard list.count < total, !isLoading else { return }
        offset += limit
        await loadPage(reset: false)
    }

    func refresh() async {
        await loadInitial()
    }

    func selectPokemon(idOrName: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let details = api.fetchPokemonDetails(idOrName)
            async let species = api.fetchPokemonSpecies(idOrName)
            let (d, s) = try await (details, species)
            self.selectedDetails = d
            self.selectedSpecies = s
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            self.selectedDetails = nil
            self.selectedSpecies = nil
        }
    }
    
    private func loadPage(reset: Bool) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let page = try await api.fetchPokemonList(limit: limit, offset: offset)
            if reset {
                self.list = page.entries
            } else {
                self.list += page.entries
            }
            self.total = page.total            
        } catch {
            self.errorMessage = (error as? LocalizedError)?.errorDescription ?? String(describing: error)
            if reset {
                self.list = []
                self.total = 0
            }
        }
    }
    
    private static func id(from url: URL) -> Int? {
        url.path.split(separator: "/").compactMap { Int($0) }.last
    }
    
    func artworkURL(for entry: PokemonEntry) -> URL? {
        guard let id = Self.id(from: entry.detailsURL) else { return nil }
        return artworkByID[id]
    }

    func ensureArtwork(for entry: PokemonEntry) async {
        guard let id = Self.id(from: entry.detailsURL), artworkByID[id] == nil else { return }
        if let url = try? await api.fetchArtworkURL(id: id) {
            artworkByID[id] = url
            await images.prefetch(url)
        }
    }
}
