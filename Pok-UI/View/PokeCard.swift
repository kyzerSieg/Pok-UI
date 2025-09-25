//// PokeCard.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 22-09-25.
//


import SwiftUI
/*
struct PokeCard: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    PokeCard()
}*/

struct PokeCard: View {
    let entry: PokemonEntry
    let imageURL: URL?
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFit()
                case .failure(_): Image(systemName: "photo").resizable().scaledToFit().padding(10)
                case .empty: ProgressView()
                @unknown default: ProgressView()
                }
            }
            .frame(width: 56, height: 56)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text(entry.name.capitalized)
                .font(.headline)

            Spacer()
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
