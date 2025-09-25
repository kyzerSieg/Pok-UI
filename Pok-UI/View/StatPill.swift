//// StatPill.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 24-09-25.
//

import SwiftUI

struct StatPill: View {
    let title: String
    let value: String
    var body: some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value).font(.headline)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

public extension PokemonEntry {
    var idFromURL: Int? {
        let comps = detailsURL.path.split(separator: "/").compactMap { Int($0) }
        return comps.last
    }
}
