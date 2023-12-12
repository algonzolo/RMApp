//
//  RMService.swift
//  RMApp
//
//  Created by Albert Garipov on 12.12.2023.
//

import Foundation

/// Primary API service to get Rick and Morty data
final class RMService {
    static let shared = RMService()
    
    private init() {}
    
    /// Send Rick and Morty API Calls
    /// - Parameters:
    ///   - _request: Request instance
    ///   - completion: Callback with data or error
    public func execute(_request: RMRequest, completion: @escaping() -> Void) {
        
    }
}
