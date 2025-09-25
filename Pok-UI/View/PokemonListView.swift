//// ContentView.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 22-09-25.
//


import SwiftUI

struct PokemonListView: View {
    @StateObject private var vm: PokeViewModel
        @State private var searchText: String = ""

        public init(viewModel: PokeViewModel) {
            _vm = StateObject(wrappedValue: viewModel)
        }

        public var body: some View {
            NavigationView {
                ZStack {
                    content
                    if vm.isLoading && vm.list.isEmpty {
                        ProgressView().scaleEffect(1.2)
                    }
                }
                .navigationTitle("Pokémon")
                .searchable(text: $searchText, prompt: "Buscar por nombre")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        if vm.isLoading && !vm.list.isEmpty {
                            ProgressView()
                        }
                    }
                }
                .task { await vm.loadInitial() }
                .refreshable { await vm.refresh() }
                .overlay(errorView, alignment: .center)
            }
        }

    private var content: some View {
        let filtered = searchText.isEmpty
            ? vm.list
            : vm.list.filter { $0.name.localizedCaseInsensitiveContains(searchText) }

        return List {
            ForEach(Array(filtered.enumerated()), id: \.offset) { idx, entry in
                NavigationLink {
                    PokemonDetailView(idOrName: entry.name, viewModel: vm)
                } label: {
                    PokeCard(entry: entry, imageURL: vm.artworkURL(for: entry))
                }
                .onAppear {
                    Task {
                        await vm.ensureArtwork(for: entry)
                        guard searchText.isEmpty else { return }
                        if idx == filtered.count - 1 { await vm.loadMore() }
                    }
                }
            }
        }
        .listStyle(.plain)
    }

    private var errorView: some View {
        Group {
            if let message = vm.errorMessage, vm.list.isEmpty {
                VStack(spacing: 12) {
                    Text(message).multilineTextAlignment(.center)
                    Button("Reintentar") {
                        Task { await vm.refresh() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
}

#Preview {
    PokemonListView(viewModel: PokeViewModel())
}

