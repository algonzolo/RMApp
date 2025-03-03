//
//  APICacheManager.swift
//  RMApp
//
//  Created by Albert Garipov on 30.01.2024.
//

import Foundation

/// Manages in memory session scoped API caches
final class APICacheManager {
    private var cacheDictionary: [RMEndpoint: NSCache<NSString, NSData>] = [:]
    private var cache = NSCache<NSString, NSData>()
    
    //MARK: - Init
    init() {
        setupCache()
    }
    
    //MARK: - Public
    
    public func readCache(for endpoint: RMEndpoint, url: URL?) -> Data? {
        guard let targetCache = cacheDictionary[endpoint],
        let url = url else { return nil }
        
        let key = url.absoluteString as NSString
        return targetCache.object(forKey: key) as? Data
    }
    
    public func setCache(for endpoint: RMEndpoint, url: URL?, data: Data) {
        guard let targetCache = cacheDictionary[endpoint],
              let url = url else { return }
        
        let key = url.absoluteString as NSString
        targetCache.setObject(data as NSData, forKey: key)
    }
    //MARK: - Private
    
    private func setupCache() {
        RMEndpoint.allCases.forEach { endpoint in
            cacheDictionary[endpoint] = NSCache<NSString, NSData>()
        }
    }
}
