//// Pok_UIApp.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 22-09-25.
//


import SwiftUI

@main
struct Pok_UIApp: App {
    var body: some Scene {
        WindowGroup {
            PokemonListView(viewModel: PokeViewModel())
        }
    }
}

