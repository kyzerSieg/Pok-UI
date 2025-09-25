//// DefaultImageCacheService.swift
// Pok-UI
//
//  Created by Mauricio Pacheco on 25-09-25.
//

import Foundation

public protocol ImageCacheServiceProtocol {
    func prefetch(_ url: URL) async
    func prefetch(_ urls: [URL]) async
    func cachedData(for url: URL) -> Data?
    func clear()
}

public final class ImageCacheService: ImageCacheServiceProtocol {
    public init(memoryMB: Int = 64, diskMB: Int = 256) {
        URLCache.shared = URLCache(
            memoryCapacity: memoryMB * 1024 * 1024,
            diskCapacity: diskMB * 1024 * 1024,
            directory: nil
        )
    }

    public func prefetch(_ url: URL) async {
        var req = URLRequest(url: url)
        req.cachePolicy = .returnCacheDataElseLoad
        _ = try? await URLSession.shared.data(for: req)
    }

    public func prefetch(_ urls: [URL]) async {
        await withTaskGroup(of: Void.self) { group in
            for u in urls {
                group.addTask { await self.prefetch(u) }
            }
        }
    }

    public func cachedData(for url: URL) -> Data? {
        let req = URLRequest(url: url)
        return URLCache.shared.cachedResponse(for: req)?.data
    }

    public func clear() {
        URLCache.shared.removeAllCachedResponses()
    }
}
