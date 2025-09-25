//// PokemonDetailView.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 24-09-25.
//


import SwiftUI

struct PokemonDetailView: View {
    let idOrName: String
    @ObservedObject var viewModel: PokeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Group {
                    if let url = artworkURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img): img.resizable().scaledToFit()
                            case .failure(_): Image(systemName: "photo").resizable().scaledToFit().padding(20)
                            case .empty: ProgressView()
                            @unknown default: ProgressView()
                            }
                        }
                        .frame(height: 200)
                    } else {
                        Rectangle().fill(Color(.secondarySystemBackground))
                            .frame(height: 200)
                            .overlay(Image(systemName: "photo"))
                    }
                }
                if let d = viewModel.selectedDetails {
                    VStack(spacing: 8) {
                        Text(d.name.capitalized)
                            .font(.largeTitle).bold()
                        HStack(spacing: 12) {
                            StatPill(title: "Altura", value: "\(d.height)")
                            StatPill(title: "Peso", value: "\(d.weight)")
                            StatPill(title: "Exp", value: "\(d.baseExperience)")
                        }
                        if !d.types.isEmpty {
                            HStack(spacing: 8) {
                                ForEach(d.types, id: \.slot) { t in
                                    Text(t.type.name.capitalized)
                                        .font(.subheadline)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(Color(.tertiarySystemFill))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                if let s = viewModel.selectedSpecies,
                    let flavor = spanishFlavor(from: s) ?? englishFlavor(from: s) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Descripción")
                            .font(.title3).bold()
                        Text(flavor)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                }
                if let message = viewModel.errorMessage {
                    Text(message)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical, 16)
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.selectPokemon(idOrName: idOrName)
        }
    }

    private var artworkURL: URL? {
        if let id = viewModel.selectedDetails?.id {
            return URL(string:
                "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/\(id).png"
            )
        }
        return nil
    }
    private func spanishFlavor(from species: PokemonSpecies) -> String? {
        species.flavorTextEntries
            .first(where: { $0.language.name == "es" })?
            .flavorText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{0C}", with: " ")
    }
    private func englishFlavor(from species: PokemonSpecies) -> String? {
        species.flavorTextEntries
            .first(where: { $0.language.name == "en" })?
            .flavorText
            .replacingOccurrences(of: "\n", with: " ")
            .replacingOccurrences(of: "\u{0C}", with: " ")
    }
}
